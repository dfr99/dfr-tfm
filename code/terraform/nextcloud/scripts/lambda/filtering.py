import json
import urllib.parse
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

ssm = boto3.client("ssm")
s3 = boto3.client("s3")
s3_resource = boto3.resource("s3")
sns = boto3.client("sns")

format = "".join(["date", "_", "license", ".extension"])
extension = {"zip": ".zip", "checksum": ".sha256"}
extensions = ["zip", "sha256"]

folderName = datetime.strftime(datetime.now(), "%Y%m%d")


def get_prefix_parameter(client, upnext: str, prefix: str, encryption: bool):
    """Permite acceder a parámetros del Parameter Store del SSM
    Args:
        client (boto3.client('ssm')): Cliente SSM
        upnext (str): Clave
        prefix (str): Ambiente
        encryption (bool): Dato con cifrado
    Returns:
        str: Valor guardado en el Parameter Store
    """
    return client.get_parameter(Name=f"/{prefix}/{upnext}", WithDecryption=encryption)[
        "Parameter"
    ]["Value"]


def snsPublish(topic_arn, subject, message):
    """Publicación genérica de una notificación.
    Args:
        topic_arn (str): Código ARN del topic de SNS en el que generar la
                        notificación
        subject (str): Asunto que aparecerá en el correo/sms
        message (str): Mensaje que aparecerá en el correo/sms
    """
    try:
        response = sns.publish(TopicArn=topic_arn, Subject=subject, Message=message)
        return
    except Exception as e:
        print(f"Error al generar la notificación. Error -> [{e}]")
        return


def publishInvalidExtension(topic_arn, key):
    """Publicación de error mediante EMAIL
    Args:
        topic_arn (str): Código ARN del topic de SNS en el que generar la
                        notificación
        key (str): Objeto de S3 procesado
    """
    Subject = "[Error] in File Upload - Invalid Extension"
    Message = f"""
    The extension of the file [{key}] does not match with the expected extensions [{extensions}].
    Please, review that the file is the correct one.
    """
    snsPublish(topic_arn=topic_arn, subject=Subject, message=Message)
    return


def publishNoLicense(topic_arn, key):
    """Publicación de error mediante EMAIL
    Args:
        topic_arn (str): Código ARN del topic de SNS en el que generar la
                        notificación
        key (str): Objeto de S3 procesado
    """
    Subject = "[Error] in File Upload - No License"
    Message = f"""
    The uploaded file [{key}] does not have any license.
    Please, review that the file is the correct one.
    """
    snsPublish(topic_arn=topic_arn, subject=Subject, message=Message)
    return


def publishInvalidDate(topic_arn, key, date):
    """Publicación de error mediante EMAIL
    Args:
        topic_arn (str): Código ARN del topic de SNS en el que generar la
                        notificación
        key (str): Objeto de S3 procesado
    """
    Subject = "[Error] in File Upload - Invalid Date"
    Message = f"""
    The uploaded file's [{key}] date [{date}] is not a valid one. The date format must be "DDMMYYYY".
    For example: June the first, 2023 would be 01062023.
    Please, review that the file is the correct one.
    """
    snsPublish(topic_arn=topic_arn, subject=Subject, message=Message)
    return


def verifyNameStructure(fileName, fileExtension, topic_arn):
    """Verificar la estructura del nombre del archivo. Es importante, ya
    que debe incluir la fecha de descarga y la licencia. En caso contrario
    se reportará.
    Args:
        fileName (str): Nombre del archivo
        fileExtension (str): Extensión del archivo
        topic_arn (str): Código ARN del topic de SNS en el que generar la
                        notificación
    Returns:
        bool: Booleano indicando si se debe de continuar la ejecución o no.
    """
    nameList = fileName.split(sep="_")
    fileDate = nameList[0]
    fileLicense = nameList[1]
    if fileLicense == "":
        publishNoLicense(
            topic_arn=topic_arn, key="".join([fileName, ".", fileExtension])
        )
        return False
    try:
        date = datetime.strptime(fileDate, "%d%m%Y")
        return True
    except Exception as e:
        print(f"Error al leer la fecha. Error -> [{e}]")
        publishInvalidDate(
            topic_arn=topic_arn,
            key="".join([fileName, ".", fileExtension]),
            date=fileDate,
        )
        return False


def existsPairFile(fileName, fileExtension, bucket, key):
    """Búsqueda del fichero 'par'. El copiado se realiza SIEMPRE con el segundo en llegar.
    Se realiza la creación del nombre 'esperado' del otro objeto (haciendo la sustitución
    de la extensión), para a continuación buscarlo.
    Args:
        fileName (str): Nombre sin extensión del archivo (parte común a ambos)
        fileExtension (str): Extensión del archivo en procesado. Buscaremos el archivo con la
        otra extensión
        bucket (str): Bucket de recepción de los archivos
        key (str): Ruta completa del objeto en procesado.
    Raises:
        e: En caso de error inesperado, se alza.
    Returns:
        bool: _description_
    """
    # Obtener nombre (Fecha_Licencia)
    searchExtension = (
        extension["zip"]
        if fileExtension == extension["checksum"]
        else extension["checksum"]
    )

    searchKey = "".join(
        [key.rsplit(sep="/", maxsplit=1)[0], "/", fileName, searchExtension]
    )

    try:
        response = s3.get_object(Bucket=bucket, Key=searchKey)
        return True
    except ClientError as e:
        if e.response["Error"]["Code"] == "NoSuchKey":
            print("No se encuentra el par; esperar por él")
            return False
        else:
            print(f"Error inesperado -> [{e}]")
            raise e


def main(bucket, key):
    # Obtener prefijo ambiente
    environment = bucket.rsplit(sep="-", maxsplit=1)[-1]
    PREFIX = "pro" if environment == "pro" else "test"
    topic_arn = get_prefix_parameter(
        ssm, "Moodle/Offline/arns/sns/FileVerification", PREFIX, False
    )

    # Obtener nombre del archivo
    file = key.rsplit(sep="/", maxsplit=1)[-1]

    # Obtener extensión (.zip/.sha256)
    fileList = file.split(sep=".")
    fileName = fileList[0]
    fileExtension = fileList[-1]

    if fileExtension not in extensions:
        # Notificación de error
        publishInvalidExtension(topic_arn=topic_arn, key=key)
        return

    # Verificar estructura
    next = verifyNameStructure(
        fileName=fileName, fileExtension=fileExtension, topic_arn=topic_arn
    )
    if not next:
        return

    # Verificar existencia del par
    exists = existsPairFile(
        fileName=fileName, fileExtension=fileExtension, bucket=bucket, key=key
    )
    if not exists:
        return

    # Copiar a históricos de la fecha actual.
    history_bucket = get_prefix_parameter(
        ssm, "Moodle/Offline/s3/buckets/history", PREFIX, False
    )
    moodle_prefix = get_prefix_parameter(ssm, "Moodle/Offline/s3/prefix", PREFIX, False)
    history_bucket = (
        "".join([history_bucket, "pro"])
        if PREFIX == "pro"
        else "".join([history_bucket, "dev"])
    )
    # 1. Coger bucket de históricos
    dest_bucket = history_bucket
    # 2. CP dentro de folder
    key_no_extension = key.rsplit(sep=".", maxsplit=1)[0]
    try:
        for ext in extension:
            src_key = "".join([key_no_extension, extension[ext]])
            dest_key = "".join(
                [moodle_prefix, "/", folderName, "/", fileName, extension[ext]]
            )
            print(f"Source Bucket = [{bucket}] ; Destination Bucket = [{dest_bucket}]")
            print(f"Source Key = [{src_key}] ; Destination Key = [{dest_key}]")

            response = s3.copy_object(
                Bucket=dest_bucket,
                Key=dest_key,
                CopySource={"Bucket": bucket, "Key": src_key},
            )

    except Exception as e:
        print(e)
        print("Error al copiar")
    # TODO:  Crear la lambda que se lance cuando se incluyan archivos en el histórico, para que lance la verificación.
    return


def lambda_handler(event, context):
    # print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )

    print(f"Archivo recibido: [{key}]")
    main(bucket=bucket, key=key)

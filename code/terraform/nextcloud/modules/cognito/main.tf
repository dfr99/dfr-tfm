# TODO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool
resource "aws_cognito_user_pool" "pool" {
  name = var.cognito_user_pool_name

  # mfa_configuration = var.cognito_mfa_configuration
  # sms_authentication_message = var.cognito_sms_authentication_message

  # sms_configuration {
  #   external_id = var.cognito_sms_configuration_external_id
  #   sns_caller_arn = var.cognito_sms_configuration_sns_caller_arn
  #   sns_region = var.cognito_sms_configuration_sns_region
  # }

  # software_token_mfa_configuration {
  #   enabled = var.cognito_software_token_mfa_configuration_enabled
  # }

  # account_recovery_setting {
  #   # Bucle para varios métodos de recuperación
  #   recovery_mechanism {
  #     name = var.cognito_account_recovery_setting_recovery_mechanism_name
  #     priority = var.cognito_account_recovery_setting_recovery_mechanism_priority
  #   }
  # }

  # schema {
  #   attribute_data_type = "String"
  #   developer_only_attribute = false
  #   mutable = true
  #   name = "name"
  #   required = true
  #   string_attribute_constraints {
  #     max_length = 50
  #     min_length = 1
  #   }

  # schema {
  #   attribute_data_type = "String"
  #   developer_only_attribute = false
  #   mutable = true
  #   name = "email"
  #   required = true
  #   string_attribute_constraints {
  #     max_length = 50
  #     min_length = 1
  #   }
  # }

  # schema {
  #   attribute_data_type = "String"
  #   developer_only_attribute = false
  #   mutable = true
  #   name = "phone"
  #   required = true
  #   string_attribute_constraints {
  #     max_length = 50
  #     min_length = 1
  #   }
  # }

  # schema {
  #   attribute_data_type = "String"
  #   developer_only_attribute = false
  #   mutable = true
  #   name = "birthday"
  #   required = true
  #   string_attribute_constraints {
  #     max_length = 50
  #     min_length = 1
  #   }
  # }

  # schema {
  #   attribute_data_type = "String"
  #   developer_only_attribute = false
  #   mutable = true
  #   name = "age"
  #   required = true
  #   string_attribute_constraints {
  #     max_length = 50
  #     min_length = 1
  #   }
  # }

  # schema {
  #   attribute_data_type = "String"
  #   developer_only_attribute = false
  #   mutable = true
  #   name = "address"
  #   required = true
  #   string_attribute_constraints {
  #     max_length = 50
  #     min_length = 1
  #   }
  # }
}

# TODO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user
resource "aws_cognito_user" "users" {
  count       = length(var.cognito_user_usernames)
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = var.cognito_user_usernames[count.index]["username"]

  # atrributes = {
  #   name =  each.key[full_name]
  #   email =  each.key[email]
  #   phone = each.key[phone]
  #   birthday = each.key[birthday]
  #   age = each.key[age]
  #   address = each.key[address]
  # }
}
CREATE TABLE `moodle_offline_loads` (
  `id` VARCHAR(36) NOT NULL,
  `sfn_arn` VARCHAR(255) NOT NULL,
  `sfn_arn_glue` VARCHAR(255) NOT NULL,
  `file_name` VARCHAR(255) NOT NULL,
  `send_mode` VARCHAR(6) NOT NULL,
  `reception_datetime` DATETIME NOT NULL,
  `last_state` VARCHAR(255) NULL,
  `error` VARCHAR(255) NULL,
  `error_datetime` DATETIME NULL,
  `error_aws_lambda_id` VARCHAR(255) NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `moodle_offline_reports` (
  `id` VARCHAR(36) NOT NULL,
  `license` VARCHAR(255) NOT NULL,
  `report_date` DATE NOT NULL,
  PRIMARY KEY (`id`)
);

ALTER TABLE `moodle_offline_reports` ADD UNIQUE `license_report_date_index`(`license`, `report_date`);

CREATE TABLE `moodle_offline_processings` (
  `report_id` VARCHAR(36) NULL,
  `load_id` VARCHAR(36) NOT NULL,
  `created_datetime` DATETIME NOT NULL,
  FOREIGN KEY (`load_id`)
        REFERENCES `moodle_offline_loads` (`id`)
        ON DELETE CASCADE,
  FOREIGN KEY (`report_id`)
        REFERENCES `moodle_offline_reports` (`id`)
);

ALTER TABLE `moodle_offline_processings` ADD UNIQUE `report_load_index`(`report_id`, `load_id`);

DROP TABLE IF EXISTS `schedules`, `schedule_status`;
CREATE TABLE `schedule_status` (
  `code` varchar(50) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB;

INSERT INTO `schedule_status` (`code`) VALUES
('SCHEDULED'),
('ACTIVE'),
('DONE'),
('CANCELED'),
('FAILED'),
('DISABLED');

  
DROP TABLE IF EXISTS `schedules`;
CREATE TABLE `schedules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `status` varchar(50) CHARACTER SET utf8 NOT NULL,
  `schedule` varchar(100) CHARACTER SET utf8 NOT NULL,
  `module` varchar(100) CHARACTER SET utf8 NOT NULL,
  `method` varchar(100) CHARACTER SET utf8 NOT NULL,
  `params` BLOB,
  `last_start` DATETIME,
  `last_end` DATETIME,
  `last_status` varchar(50) CHARACTER SET utf8, 
  `last_result` varchar(300) CHARACTER SET utf8, 
  `description` varchar(300) CHARACTER SET utf8, 
  FOREIGN KEY (`status`) REFERENCES `schedule_status` (`code`),
  FOREIGN KEY (`last_status`) REFERENCES `schedule_status` (`code`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

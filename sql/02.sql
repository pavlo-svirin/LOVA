SET NAMES 'utf8';
SET `character_set_client` = 'utf8';
SET `character_set_results` = 'utf8';
SET `collation_connection` = 'utf8_general_ci';

DROP TABLE IF EXISTS `options`;
CREATE TABLE `options` (
  `name` varchar(100) CHARACTER SET utf8 NOT NULL UNIQUE,
  `value` TEXT DEFAULT ''
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `first_name` varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `last_name` varchar(300) CHARACTER SET utf8 DEFAULT '',
  `email` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `password` varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `created` datetime DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  `referal` varchar(100) CHARACTER SET utf8 DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `user_profile`;
CREATE TABLE `user_profile` (
  `user_id` int(10) unsigned NOT NULL,
  `name` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `value`  varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT ''
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `user_account`;
CREATE TABLE `user_account` (
  `user_id` int(10) unsigned NOT NULL,
  `personal` NUMERIC(10,2) DEFAULT 0,
  `fond` NUMERIC(10,2) DEFAULT 0,
  `referal` NUMERIC(10,2) DEFAULT 0,
  PRIMARY KEY (`user_id`)
) ENGINE=MyISAM;

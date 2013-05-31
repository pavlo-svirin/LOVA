SET NAMES 'utf8';
SET `character_set_client` = 'utf8';
SET `character_set_results` = 'utf8';
SET `collation_connection` = 'utf8_general_ci';

DROP TABLE IF EXISTS `options`;
CREATE TABLE `options` (
  `name` varchar(100) CHARACTER SET utf8 NOT NULL UNIQUE,
  `value` varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT ''
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `first_name` varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `last_name` varchar(300) CHARACTER SET utf8 DEFAULT '',
  `email` varchar(100) CHARACTER SET utf8 DEFAULT '',
  `password` varchar(300) CHARACTER SET utf8 DEFAULT '',
  `created` datetime DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `user_profile`;
CREATE TABLE `user_profile` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

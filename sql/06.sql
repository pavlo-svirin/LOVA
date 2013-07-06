DROP TABLE IF EXISTS `email_templates`;
CREATE TABLE `email_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `lang` varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `subject` varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `body` TEXT CHARACTER SET utf8  DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

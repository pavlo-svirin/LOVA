DROP TABLE IF EXISTS `html_content`;
CREATE TABLE `html_content` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `lang` varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `content` TEXT CHARACTER SET utf8  DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `tickets`;
CREATE TABLE `tickets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) NOT NULL,
  `numbers` varchar(300) CHARACTER SET utf8 NOT NULL,
  `games` int(8) unsigned not null,
  `games_left` int(8) unsigned not null,
  `created` datetime DEFAULT NULL,
  `paid` datetime DEFAULT NULL,
  `game_price` decimal(5,2) unsigned,
  
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `games_history`;
CREATE TABLE `games_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `game_id` int(10) unsigned NOT NULL,
  `ticket_id` int(10) unsigned NOT NULL,
  `guessed` int(8) unsigned not null,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `games`;
CREATE TABLE `games` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `lucky_numbers` varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sum` numeric(8,2) unsigned NOT NULL,
  `max_number` int(10) unsigned NOT NULL,
  `count_numbers` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

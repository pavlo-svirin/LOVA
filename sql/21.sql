ALTER TABLE `options` ENGINE=InnoDB;
ALTER TABLE `users` ENGINE=InnoDB;
ALTER TABLE `user_account` ENGINE=InnoDB;
ALTER TABLE `user_profile` ENGINE=InnoDB;

DROP TABLE IF EXISTS `tickets`;
CREATE TABLE `tickets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) NOT NULL,
  `numbers` varchar(300) CHARACTER SET utf8 NOT NULL,
  `games` int(8) unsigned not null,
  `games_left` int(8) unsigned not null,
  `created` datetime NOT NULL,
  `paid` datetime DEFAULT NULL,
  `game_price` decimal(5,2) unsigned,
  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `games`;
CREATE TABLE `games` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `schedule` datetime NOT NULL,
  `lucky_numbers` varchar(300) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sum` numeric(8,2) unsigned NOT NULL,
  `users` int(10) unsigned NOT NULL,
  `tickets` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `game_tickets`;
CREATE TABLE `game_tickets` (
  `game_id` int(10) unsigned NOT NULL,
  `ticket_id` int(10) unsigned NOT NULL,
  `guessed` int(10) unsigned not null
) ENGINE=InnoDB;
CREATE INDEX game_id_idx ON `game_tickets` (`game_id`);

DROP TABLE IF EXISTS `game_stats`;
CREATE TABLE `game_stats` (
  `game_id` int(10) unsigned NOT NULL,
  `guessed` int(8) unsigned NOT NULL,
  `tickets` int(10) unsigned not null,
  `users` int(10) unsigned not null  
) ENGINE=InnoDB;
CREATE INDEX game_id_idx ON `game_stats` (`game_id`);

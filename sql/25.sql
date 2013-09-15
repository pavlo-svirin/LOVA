DROP TABLE IF EXISTS `user_stats`;
CREATE TABLE `user_stats` (
  `user_id` int(10) unsigned NOT NULL,
  `game_id` int(10) unsigned NOT NULL,
  `tickets` int(10) unsigned DEFAULT 0,
  `bonus` int(10) unsigned DEFAULT 0,
  PRIMARY KEY (`user_id`, `game_id`)
) ENGINE=InnoDB;


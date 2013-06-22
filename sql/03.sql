SET NAMES 'utf8';
SET `character_set_client` = 'utf8';
SET `character_set_results` = 'utf8';
SET `collation_connection` = 'utf8_general_ci';

DROP TABLE IF EXISTS `value_flags`;
CREATE TABLE `value_flags` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8 NOT NULL UNIQUE,
  `comment` varchar(300) CHARACTER SET utf8,
    PRIMARY KEY (`id`)
) ENGINE=MyISAM;

INSERT INTO `value_flags` (`name`, `comment`) VALUES ('system', "System value, should not be updated via UI");

ALTER TABLE `user_profile` ADD COLUMN `flag_id` int(10) unsigned;
UPDATE `user_profile` SET `flag_id` = 0;
UPDATE `user_profile` SET `flag_id` = 1 WHERE `name` = 'activated';
UPDATE `user_profile` SET `flag_id` = 1 WHERE `name` = 'emailCode';
UPDATE `user_profile` SET `flag_id` = 1 WHERE `name` = 'validateEmail';

ALTER TABLE `options` ADD COLUMN `flag_id` int(10) unsigned;
UPDATE `options` SET `flag_id` = 1 WHERE `name` = 'like';
UPDATE `options` SET `flag_id` = 1 WHERE `name` = 'nextAccountTime';

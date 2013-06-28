SET NAMES 'utf8';
SET `character_set_client` = 'utf8';
SET `character_set_results` = 'utf8';
SET `collation_connection` = 'utf8_general_ci';

ALTER TABLE `users` MODIFY COLUMN `login` varchar(100) CHARACTER SET utf8 DEFAULT '';

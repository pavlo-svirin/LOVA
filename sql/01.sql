SET NAMES 'utf8';
SET `character_set_client` = 'utf8';
SET `character_set_results` = 'utf8';
SET `collation_connection` = 'utf8_general_ci';


DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  id        CHAR(32) NOT NULL UNIQUE,
  a_session TEXT character set utf8 NOT NULL
) ENGINE=MyISAM;

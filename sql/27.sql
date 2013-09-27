ALTER TABLE `tickets` CHANGE COLUMN `tricky_num` `lova_number` int(8) unsigned;
ALTER TABLE `games` ADD COLUMN `lova_number` int(8) unsigned;
ALTER TABLE `game_tickets` ADD COLUMN `lova_number_distance` int(8);
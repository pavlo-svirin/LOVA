CREATE INDEX referal_idx ON `users` (`referal`);
CREATE INDEX email_idx ON `users` (`email`);

ALTER TABLE `tickets` ADD COLUMN `tricky_num` int(8) unsigned;
INSERT INTO `html_content` (lang, page, code, type, content) VALUES
('ru', 'CABINET', 'SMALL_COUNTDOWN_HEADER', 'STRING', 'Общее количество регистраций:');

INSERT INTO `html_content` (lang, page, code, type, content) VALUES
('en', 'CABINET', 'SMALL_COUNTDOWN_HEADER', 'STRING', 'Общее количество регистраций:');

INSERT INTO `html_content` (lang, page, code, type, content) VALUES
('ua', 'CABINET', 'SMALL_COUNTDOWN_HEADER', 'STRING', 'Общее количество регистраций:');

UPDATE `html_content` SET `content`='Подтверждённые регистрации' WHERE `code`='ACCOUNT_REGISTERED' AND  `page`='CABINET';
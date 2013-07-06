-- drop duplicata entries on user_profile table
ALTER IGNORE T ALTER IGNORE TABLE user_profile ADD UNIQUE INDEX idx_user_name (user_id, name ); 
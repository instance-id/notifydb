
CREATE TABLE notification_data (
  id INTEGER NOT NULL PRIMARY KEY,
  sender VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMP UNIQUE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  unread BOOLEAN NOT NULL DEFAULT 0
);

SELECT diesel_manage_updated_at('notification_data');


--Create before update and after insert triggers:


-- CREATE TRIGGER UPDATE_notification_data BEFORE UPDATE ON notification_data
--     BEGIN
--        UPDATE notification_data SET updated_at = datetime('now', 'localtime')
--        WHERE rowid = new.rowid;
--     END

-- CREATE TRIGGER INSERT_notification_data AFTER INSERT ON notification_data
--     BEGIN
--        UPDATE notification_data SET created_at = datetime('now', 'localtime')
--        WHERE rowid = new.rowid;
--     END
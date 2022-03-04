mod schema;

use std::io::Write;
use std::path::{Path, PathBuf};

pub use config::*;
use diesel::connection::SimpleConnection;
use diesel::dsl::sql;
use diesel::sql_types::Bool;

#[macro_use]
extern crate lazy_static;

use std::env;
use std::sync::RwLock;

extern crate chrono;

use chrono::NaiveDateTime;

#[macro_use]
extern crate diesel;

use diesel::{prelude::*, select, sql_query};

#[macro_use]
extern crate serde_derive;
extern crate serde_json;

use simplelog::*;
use std::fs::File;
use std::str::FromStr;

//region --| Database Schema ---------------
pub use self::diesel::query_builder::QueryBuilder;
use crate::schema::{notification_data, settings_data};
//endregion

//region --| Database Models ---------------
#[derive(Deserialize, Insertable)]
#[table_name = "notification_data"]
pub struct NewNotification<'a> {
    sender: &'a str,
    title: Option<&'a str>,
    body: Option<&'a str>,
    actions: Option<&'a str>,
    hints: Option<&'a str>,
    icon: Option<&'a str>,
    timeout: i32,
    unread: bool,
}

#[derive(Queryable, PartialEq, Debug, Serialize)]
// --| Notification Model -----------------------
pub struct Notification {
    id: i32,
    sender: String,
    title: Option<String>,
    body: Option<String>,
    actions: Option<String>,
    hints: Option<String>,
    icon: Option<String>,
    timeout: i32,
    unread: bool,
    archived: bool,
    created_at: NaiveDateTime,
    updated_at: NaiveDateTime,
}

#[allow(dead_code)]
#[derive(Clone)]
pub struct NotificationMsg {
    pub appname: String,
    pub replaces_id: u32,
    pub summary: String,
    pub body: String,
    pub actions: Vec<String>,
    pub hints: Vec<String>,
    pub icon: String,
    pub timeout: i32,
    pub unread: bool,
}

// --| Settings Model ---------------------------
#[derive(Queryable, PartialEq, Debug, Serialize)]
pub struct SettingsData {
    id: i32,
    application: String,
    settings_json: String,
    created_at: NaiveDateTime,
    updated_at: NaiveDateTime,
}

#[derive(Deserialize, Insertable)]
#[table_name = "settings_data"]
pub struct NewSettingsData<'a> {
    application: &'a str,
    settings_json: &'a str,
}

//endregion

lazy_static! {
    pub static ref SETTINGS: RwLock<config::Config> = RwLock::new(config::Config::default());
}

// --| Locate or create configuration directory -
// --|-------------------------------------------
#[cfg(not(any(target_os = "macos", windows)))]
pub fn get_config_path(name: &str) -> PathBuf {
    use std::fs;

    let key = "HOME";
    match env::var(key) {
        Ok(val) => debug!("{}: {:?}", key, val),
        Err(e) => error!("couldn't interpret {}: {}", key, e),
    }

    let mut path = PathBuf::new();
    let mut home = env::var(key).expect("Failed to get home dir");
    home.push_str(format!("/.config/{}", name.to_lowercase()).as_str());
    path.push(home);

    fs::create_dir_all(path.clone()).expect("Failed to create config dir");

    if Path::new(&path).exists() {
        let mut settings_path = match path.join("settings.toml").to_str() {
            Some(p) => PathBuf::from(p),
            None => std::path::PathBuf::from("settings"),
        };

        if !Path::new(&settings_path).exists() {
            let settings_file = default_settings(path.clone());
            settings_path = settings_file;
        }

        debug!("{:?}", settings_path);
        let mut settings = SETTINGS.write().unwrap();
        if let Err(err) = settings.merge(config::File::from(settings_path)) {
            warn!("settings merge failed, use default settings, err: {}", err);
        }
    } else {
        warn!("Failed to get config directory or file");
    }

    path
}

// --| Initialize logging -----------------------
// --|-------------------------------------------
pub fn init_logging(config_path: PathBuf) -> PathBuf {
    let mut default_level = LevelFilter::Warn;
    let mut settings = SETTINGS.write().unwrap();

    // --| If env variable is provided, it will override other log level settings --
    if let Ok(v) = env::var("RUST_LOG") {
        default_level = LevelFilter::from_str(&v).unwrap_or(LevelFilter::Warn);
    } else if let Ok(l) = settings.get_str("database.logLevel") {
        default_level = LevelFilter::from_str(&l).unwrap();
    }

    let logging_config = ConfigBuilder::new().set_location_level(default_level).set_time_to_local(true).build();
    let log_path = config_path.join("notifydb.log");

    CombinedLogger::init(vec![
        TermLogger::new(default_level, logging_config.clone(), TerminalMode::Mixed, ColorChoice::Auto),
        WriteLogger::new(default_level, logging_config, File::create(log_path).unwrap()),
    ])
    .unwrap();

    let db_url;
    // --| Set default database path -------------
    if let Ok(u) = settings.get_str("database.databaseUrl") {
        db_url = u;
    } else {
        db_url = format!("file:{}/notify.db", config_path.to_str().unwrap());
    }

    settings.set("database.databaseUrl", db_url.clone()).unwrap();
    config_path
}

// --| Initialize database connection -----------
// --|-------------------------------------------
pub fn establish_connection() -> SqliteConnection {
    let settings = SETTINGS.read().unwrap();
    let database_url = settings.get_str("database.databaseUrl").unwrap();

    let conn = SqliteConnection::establish(&database_url).unwrap_or_else(|_| panic!("Error connecting to {}", database_url));

    conn.batch_execute(
        "
    PRAGMA journal_mode = WAL;          -- better write-concurrency
    PRAGMA synchronous = NORMAL;        -- fsync only in critical moments
    PRAGMA wal_autocheckpoint = 1000;   -- write WAL changes back every 1000 pages, for an in average 1MB WAL file. May affect readers if number is increased
    PRAGMA wal_checkpoint(TRUNCATE);    -- free some space by truncating possibly massive WAL files from the last run.
    PRAGMA busy_timeout = 250;          -- sleep if the database is busy
    PRAGMA foreign_keys = ON;           -- enforce foreign keys
",
    )
    .map_err(ConnectionError::CouldntSetupConfiguration).expect("Failed to setup database configuration");

    conn
}

// --| Notifications ----------------------------
// --|-------------------------------------------
pub fn insert_notification(conn: &mut SqliteConnection, notification: NotificationMsg) -> usize {
    let mut actions = notification.actions.join(";");
    let mut hints = notification.hints.join(";");

    if actions.is_empty() {
        actions = "".parse().unwrap();
    }

    if hints.is_empty() {
        hints = "".parse().unwrap();
    }

    let new_post = NewNotification {
        sender: notification.appname.as_str(),
        title: Some(notification.summary.as_str()),
        body: Some(notification.body.as_str()),
        unread: notification.unread,
        actions: Some(actions.as_str()),
        hints: Some(hints.as_str()),
        icon: Some(notification.icon.as_str()),
        timeout: notification.timeout,
    };
    let result = diesel::insert_into(notification_data::table).values(&new_post).execute(conn);

    return match result {
        Ok(_) => {
            debug!("Inserted new notification");
            1
        }
        Err(err) => {
            error!("Error inserting new notification: {}", err);
            0
        }
    };
}

// --| Get total notification count -------------
pub fn get_notification_count() -> i64 {
    let conn = establish_connection();

    let query = notification_data::table
        .select(diesel::dsl::count(notification_data::id))
        .filter(notification_data::unread.eq(true));

    let result = query.load::<i64>(&conn).unwrap();
    return *result.get(0).unwrap();
}

// --| Get notifications from database ----------
pub fn get_notifications(load_count: i64) -> String {
    use crate::notification_data::dsl::*;

    let results: Vec<Notification>;
    let conn = establish_connection();
    if load_count == 0 {
        results = notification_data.filter(unread.eq(true)).load::<Notification>(&conn).expect("Error loading notifications");
    } else {
        results = notification_data
            .filter(unread.eq(true))
            .limit(load_count)
            .load::<Notification>(&conn)
            .expect("Error loading notifications");
    }

    serde_json::to_string(&results).unwrap_or_else(|err| {
        debug!("Error serializing to json: {}", err);
        String::from("Not_found")
    })
}

// Delete all notifications by id from vector list
pub fn delete_notifications(ids: Vec<i32>) -> String {
    use crate::notification_data::dsl::*;
    let conn = establish_connection();
    let mut deleted_count = 0;

    for _id in &ids {
        let result = diesel::delete(notification_data.filter(id.eq(_id))).execute(&conn);

        match result {
            Ok(_) => {
                debug!("Deleted notification with id {}", _id);
                deleted_count += 1;
            }
            Err(err) => {
                error!("Error deleting notification: {}", err);
            }
        }
    }

    if deleted_count == ids.len() {
        String::from("Success")
    } else {
        String::from("Error")
    }
}

// --| Mark notifications status as read --------
pub fn mark_notifications_as_read(ids: Vec<i32>) -> String {
    use crate::notification_data::dsl::*;

    let conn = establish_connection();

    let result = diesel::update(notification_data.filter(id.eq_any(ids))).set(unread.eq(false)).execute(&conn);

    return match result {
        Ok(_) => {
            debug!("Marked notifications as read");
            String::from("Success")
        }
        Err(err) => {
            error!("Error marking notifications as read: {}", err);
            String::from("Error")
        }
    };
}

// Insert settings data into settings_data table via application field, update if exists
pub fn upsert_settings(application: &str, settings_json: &str) -> String {
    let conn = establish_connection();
    let new_settings = NewSettingsData {
        application: application,
        settings_json: settings_json,
    };
    let result = diesel::replace_into(settings_data::table).values((settings_data::id.eq(1), &new_settings)).execute(&conn);

    return match result {
        Ok(_) => {
            debug!("Inserted new settings");
            String::from("Success")
        }
        Err(err) => {
            error!("Error inserting new settings: {}", err);
            String::from("Error")
        }
    };
}

pub fn update_settings(app_name: &str, settings_str: &str) -> String {
    use crate::settings_data::dsl::*;

    let conn = establish_connection();
    let result = diesel::update(settings_data.filter(application.eq(app_name)))
        .set(settings_json.eq(settings_str))
        .execute(&conn);

    return match result {
        Ok(_) => {
            debug!("Updated settings");
            String::from("Success")
        }
        Err(err) => {
            error!("Error updating settings: {}", err);
            String::from("Error")
        }
    };
}

// Get settings_data table via application field
pub fn get_settings(app_name: &str) -> String {
    use crate::settings_data::dsl::*;

    let conn = establish_connection();
    let result = settings_data.filter(application.eq(app_name)).load::<SettingsData>(&conn).expect("Error loading settings");

    serde_json::to_string(&result).unwrap_or_else(|err| {
        debug!("Error serializing to json: {}", err);
        String::from("Not_found")
    })
}

pub fn default_settings(settings: PathBuf) -> PathBuf {
    let settings_path = Path::new(&settings).join("settings.toml");

    let mut settings_file = File::create(&settings_path).unwrap();
    let settings_toml = r##"
[database]
logLevel = "error"
databaseUrl = "file:{{PATH}}/notify.db"

[viewer]
# --| Placeholder -----------
"##;

    let toml = settings_toml.replace("{{PATH}}", &settings.to_str().unwrap());
    settings_file.write_all(toml.as_bytes()).unwrap();
    settings_path
}

pub fn setup() {
    let conn = establish_connection();

    let notify_schema = r#"
        CREATE TABLE notification_data (
            id INTEGER NOT NULL PRIMARY KEY,
            sender VARCHAR NOT NULL,
            title VARCHAR NOT NULL,
            body TEXT NOT NULL,
            actions TEXT,
            hints TEXT,
            icon TEXT,
            timeout INTEGER,
            created_at TIMESTAMP UNIQUE NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
            updated_at TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
            archived BOOLEAN NOT NULL DEFAULT 0,
            unread BOOLEAN NOT NULL DEFAULT 0
        );"#;

    let update_schema = r#"
          SELECT diesel_manage_updated_at('notification_data');"#;

    let settings_schema = r#"
        CREATE TABLE settings_data (
            id INTEGER NOT NULL PRIMARY KEY,
            application VARCHAR UNIQUE NOT NULL,
            settings_json TEXT NOT NULL,
            created_at TIMESTAMP UNIQUE NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
            updated_at TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW'))
          );"#;

    let index_schema = r#"
        CREATE UNIQUE INDEX application_name ON settings_data(application);"#;

    let insert_settings = r#"
        INSERT INTO settings_data (application, settings_json)
        VALUES ('notifydb','{"appName":"notifydb","settings":{"autoRefresh":"true","autoRefreshInterval":3,"refreshOnMarkAsRead":"false","animations":"true","maxLoadedMessages":1000,"maxPerPage":100,"deleteReadMessages":"true","logLevel":"error"}}');
        "#;

    match select(sql::<Bool>(
        "EXISTS \
         (SELECT 1 \
         FROM sqlite_master \
         WHERE type = 'table' \
         AND name = 'notification_data')",
    ))
    .get_result::<bool>(&conn)
    {
        Err(err) => {
            error!("Error querying table: {:?}", err);
            panic!("Error querying table: {:?}", err)
        }
        Ok(true) => info!("Table exists"),
        Ok(false) => {
            info!("notification_data table not found. Creating table.");
            match sql_query(notify_schema).execute(&conn) {
                Ok(_) => info!("notification_data table created"),
                Err(err) => {
                    error!("Error creating table: {:?}", err);
                    panic!("Error creating table: {:?}", err);
                }
            }
            match sql_query(update_schema).execute(&conn) {
                Ok(_) => info!("Date formatting applied"),
                Err(err) => {
                    error!("Error creating table: {:?}", err);
                    panic!("Error creating table: {:?}", err);
                }
            }
            match sql_query(settings_schema).execute(&conn) {
                Ok(_) => info!("Settings table created"),
                Err(err) => {
                    error!("Error creating table: {:?}", err);
                    panic!("Error creating table: {:?}", err);
                }
            }
            match sql_query(index_schema).execute(&conn) {
                Ok(_) => info!("Index applied"),
                Err(err) => {
                    error!("Error creating table: {:?}", err);
                    panic!("Error creating table: {:?}", err);
                }
            }
            match sql_query(insert_settings).execute(&conn) {
                Ok(_) => info!("Default settings applied"),
                Err(err) => {
                    error!("Error creating table: {:?}", err);
                    panic!("Error creating table: {:?}", err);
                }
            }
        }
    };
}

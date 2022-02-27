mod schema;

pub use config::*;
use diesel::dsl::sql;
use diesel::sql_types::Bool;
use std::path::{Path, PathBuf};

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
    unread: bool,
}

#[derive(Queryable, PartialEq, Debug, Serialize)]
// --| Notification Model -----------------------
pub struct Notification {
    id: i32,
    sender: String,
    title: Option<String>,
    body: Option<String>,
    unread: bool,
    archived: bool,
    created_at: NaiveDateTime,
    updated_at: NaiveDateTime,
}

#[allow(dead_code)]
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
        let settings_path = match path.join("settings.toml").to_str() {
            Some(p) => PathBuf::from(p),
            None => std::path::PathBuf::from("settings"),
        };

        debug!("{:?}", settings_path);
        let mut settings = SETTINGS.write().unwrap();
        if let Err(err) = settings.merge(config::File::from(settings_path)) {
            warn!("settings merge failed, use default settings, err: {}", err);
        }
    } else {
        // TODO: create default settings if not exists

        warn!("Failed to get config directory or file");
    }

    path
}

// fn set_db_url(db_url: String) -> Result<(), Box<dyn Error>> {
//     // Set property
//     SETTINGS.write()?.set("database.databaseUrl", db_url)?;
//
//     // Get property
//     println!("property: {}", SETTINGS.read()?.get::<String>("database.databaseUrl")?);
//     Ok(())
// }

// --| Initialize logging -----------------------
// --|-------------------------------------------
pub fn init_logging() -> PathBuf {
    let config_path = get_config_path("notifydb");

    let mut default_level = LevelFilter::Warn;
    let settings = SETTINGS.read().unwrap();

    // --| If env variable is provided, it will override other log level settings --
    if let Ok(v) = env::var("RUST_LOG") {
        default_level = LevelFilter::from_str(&v).unwrap_or(LevelFilter::Warn);
    } else if let Ok(l) = settings.get_str("database.logLevel") {
        default_level = LevelFilter::from_str(&l).unwrap();
    }

    println!("default_level: {:?}", default_level);

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
    println!("Setting database path to: {}", &db_url);
    // set_db_url(db_url).unwrap();

    setup();
    config_path
}

// --| Initialize database connection -----------
// --|-------------------------------------------
pub fn establish_connection() -> SqliteConnection {
    let settings = SETTINGS.read().unwrap();
    let database_url = settings.get_str("database.databaseUrl").unwrap();

    SqliteConnection::establish(&database_url).unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

// --| Notifications ----------------------------
// --|-------------------------------------------
pub fn insert_notification(conn: &mut SqliteConnection, sender: &str, title: Option<&str>, body: Option<&str>) -> usize {
    let new_post = NewNotification {
        sender,
        title,
        body,
        unread: true,
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
pub fn get_notifications() -> String {
    use crate::notification_data::dsl::*;

    let conn = establish_connection();
    let results = notification_data.filter(unread.eq(true)).load::<Notification>(&conn).expect("Error loading notifications");

    serde_json::to_string(&results).unwrap_or_else(|err| {
        debug!("Error serializing to json: {}", err);
        String::from("Not_found")
    })
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

pub fn setup() {
    let conn = establish_connection();

    let notify_schema = r#"
        CREATE TABLE notification_data (
            id INTEGER NOT NULL PRIMARY KEY,
            sender VARCHAR NOT NULL,
            title VARCHAR NOT NULL,
            body TEXT NOT NULL,
            created_at TIMESTAMP UNIQUE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
            created_at TIMESTAMP UNIQUE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          );"#;

    let index_schema = r#"
        CREATE UNIQUE INDEX application_name ON settings_data(application);"#;

    let insert_settings = r#"
        INSERT INTO settings_data (application, settings_json) VALUES ('notifydb', '{
          "appName": "notifydb",
          "settings": {
            "animations": "true",
            "autoRefresh": "true",
            "autoRefreshInterval": 3,
            "refreshOnMarkAsRead": "true",
            "logLevel": "error"
          }
        }');"#;

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

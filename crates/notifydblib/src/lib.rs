use config::Config;
use std::path::{Path, PathBuf};
#[macro_use]
extern crate lazy_static;
use std::env;
use std::sync::RwLock;

extern crate chrono;
use chrono::NaiveDateTime;

#[macro_use]
extern crate diesel;
use diesel::prelude::*;

#[macro_use]
extern crate serde_derive;
extern crate serde_json;
// use log::*;
use simplelog::*;
use std::fs::File;
use std::str::FromStr;

//region --| Database Schema ---------------
mod schema {
    table! {
        notification_data {
            id -> Integer,
            sender -> Text,
            title -> Nullable<Text>,
            body -> Nullable<Text>,
            unread -> Bool,
            created_at -> Timestamp,
            updated_at -> Timestamp,
        }
    }
}
use schema::notification_data;
//endregion
use crate::schema::notification_data::unread;

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
pub struct Notification {
    id: i32,
    sender: String,
    title: Option<String>,
    body: Option<String>,
    unread: bool,
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
//endregion

lazy_static! {
    pub static ref SETTINGS: RwLock<Config> = RwLock::new(Config::default());
}

// --| Locate or create configuration directory ----------------
// --|----------------------------------------------------------
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
    home.push_str(format!("/.config/{}", name.to_lowercase()).to_string().as_str());
    path.push(home);

    fs::create_dir_all(path.clone()).expect("Failed to create config dir");

    if Path::new(&path).exists() == true {
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
        warn!("Failed to get config directory or file");
    }

    path
}

// --| Initialize logging --------------------------------------
// --|----------------------------------------------------------
pub fn init_logging() -> PathBuf {
    let config_path = get_config_path("notifydb");

    let mut default_level = LevelFilter::Warn;
    if let Ok(v) = env::var("RUST_LOG") {
        default_level = LevelFilter::from_str(&v).unwrap_or(LevelFilter::Warn);
    }

    let logging_config = ConfigBuilder::new().set_location_level(default_level).set_time_to_local(true).build();
    let log_path = config_path.join("notifydb.log");

    CombinedLogger::init(vec![
        TermLogger::new(default_level, logging_config.clone(), TerminalMode::Mixed, ColorChoice::Auto),
        WriteLogger::new(default_level, logging_config.clone(), File::create(log_path).unwrap()),
    ])
    .unwrap();

    debug!("config_path: {:?}", config_path);
    config_path
}

// --| Initialize database connection --------------------------
// --|----------------------------------------------------------
pub fn establish_connection() -> SqliteConnection {
    let settings = SETTINGS.read().unwrap();
    let database_url = settings.get_str("database.DATABASE_URL").unwrap();
    debug!("{:?}", database_url);

    SqliteConnection::establish(&database_url).unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

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

// Get notifications from database
pub fn get_notifications() -> String {
    let conn = establish_connection();
    let results = notification_data::table
        .filter(unread.eq(true))
        .load::<Notification>(&conn)
        .expect("Error loading notifications");

    debug!("Displaying {} posts", &results.len());
    for sender in &results {
        debug!("{}", sender.sender);
        debug!("----------\n");
        debug!("{:?}", sender.body);
    }

    let json_string = serde_json::to_string(&results).unwrap_or_else(|err| {
        debug!("Error serializing to json: {}", err);
        String::from("Not_found")
    });

    return json_string;
}

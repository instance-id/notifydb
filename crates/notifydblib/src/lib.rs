use config::Config;

#[macro_use]
extern crate lazy_static;
use std::sync::RwLock;
use std::env;

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
}
//endregion

lazy_static! {
    pub static ref SETTINGS: RwLock<Config> = RwLock::new(Config::default());
}

pub fn init_logging() {

    let mut default_level = LevelFilter::Warn;
    if let Ok(v) = env::var("RUST_LOG") {
        default_level = LevelFilter::from_str(&v).unwrap_or(LevelFilter::Warn);
    }

    let logging_config = ConfigBuilder::new()
        .set_location_level(default_level)
        .build();

    CombinedLogger::init(vec![
        TermLogger::new(default_level, logging_config.clone(), TerminalMode::Mixed, ColorChoice::Auto),
        WriteLogger::new(default_level, logging_config.clone(), File::create("notifydb.log").unwrap()),
    ])
    .unwrap();
}

pub fn establish_connection() -> SqliteConnection {

    if let Ok(path) = std::env::current_exe() {
        let settings_path = match path.parent() {
            Some(parent) => parent.join("settings"),
            None => std::path::PathBuf::from("settings"),
        };

        println!("{:?}", settings_path);
        let mut settings = SETTINGS.write().unwrap();
        if let Err(err) = settings.merge(config::File::from(settings_path)) {
            warn!("settings merge failed, use default settings, err: {}", err);
        }
    }

    let settings = SETTINGS.read().unwrap();
    let database_url = settings.get_str("database.DATABASE_URL").unwrap();
    println!("{:?}", database_url);

    SqliteConnection::establish(&database_url).unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

pub fn insert_notification(conn: &mut SqliteConnection, sender: &str, title: Option<&str>, body: Option<&str>) -> usize {
    let new_post = NewNotification { sender, title, body };

    let result = diesel::insert_into(notification_data::table).values(&new_post).execute(conn);

    return match result {
        Ok(_) => {
            println!("Inserted new notification");
            1
        }
        Err(err) => {
            println!("Error inserting new notification: {}", err);
            0
        }
    }
}

// Get notifications from database
pub fn get_notifications() -> String {
    let conn = establish_connection();
    let results = notification_data::table.filter(unread.eq(true)).limit(1).load::<Notification>(&conn).expect("Error loading notifications");

    println!("Displaying {} posts", &results.len());
    for sender in &results {
        println!("{}", sender.sender);
        println!("----------\n");
        println!("{:?}", sender.body);
    }

    let json_string = serde_json::to_string(&results).unwrap_or_else(|err| {
        println!("Error serializing to json: {}", err);
        String::from("Not_found")
    });

    return json_string;
}

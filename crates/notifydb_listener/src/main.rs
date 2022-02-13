extern crate dbus;

// --| datetime ------------------
use chrono::{DateTime, Local};

use dbus::arg::{self, RefArg};
use dbus::blocking::Connection;
use dbus::channel::MatchingReceiver;
use dbus::message::{MatchRule, MessageType};
use lazy_static::lazy_static;
use log::debug;
use log::*;
use notifydblib::{establish_connection, init_logging, insert_notification, NotificationMsg};
use std::process;
use std::sync::{Arc, Mutex};
use std::time::Duration;

lazy_static! {
    static ref PREVMSG: Arc<Mutex<NotificationMsg>> = {
        let m = NotificationMsg {
            appname: "".to_string(),
            replaces_id: 0,
            summary: "".to_string(),
            body: "".to_string(),
            actions: vec![],
            hints: vec![],
            icon: "".to_string(),
            timeout: 0,
            unread: true,
        };
        Arc::new(Mutex::new(m))
    };
}

lazy_static! {
    static ref TIMESTAMP: Arc<Mutex<DateTime<Local>>> = {
        let m = Local::now();
        Arc::new(Mutex::new(m))
    };
}

fn main() -> () {
    init_logging();

    let conn = Connection::new_session().unwrap_or_else(|_| {
        error!("Couldn't connect tofailed to connect to session bus");
        process::exit(1);
    });

    let mut mr = MatchRule::new_signal("org.freedesktop.Notifications", "Notify");
    mr.msg_type = Some(MessageType::MethodCall);

    let proxy = conn.with_proxy("org.freedesktop.DBus", "/org/freedesktop/DBus", Duration::from_millis(5000));
    let _: () = proxy.method_call("org.freedesktop.DBus", "AddMatch", (mr.match_str(),)).unwrap_or_else(|_| {
        error!("failed on method call 'AddMatch'");
        process::exit(1);
    });

    let filter = vec!["type='method_call',interface='org.freedesktop.Notifications',member='Notify'"];
    let _: () = proxy.method_call("org.freedesktop.DBus.Monitoring", "BecomeMonitor", (filter, 0u32)).unwrap_or_else(|_| {
        error!("failed on method call 'BecomeMonitor'");
        process::exit(1);
    });

    info!("notifydb: start listening");

    conn.start_receive(
        mr,
        Box::new(|msg, _| {
            let current_ts = Local::now();
            let mut ts = TIMESTAMP.lock().unwrap();
            let mut pm = PREVMSG.lock().unwrap();

            let mut i = msg.iter_init();
            let appname: String = i.read().unwrap_or_default();
            let replaces_id: u32 = i.read().unwrap_or_default();
            let icon: String = i.read().unwrap_or_default();
            let summary: String = i.read().unwrap_or_default();
            let body: String = i.read().unwrap_or_default();
            let actions: Vec<String> = i.read().unwrap_or_default();
            let hints: ::std::collections::HashMap<String, arg::Variant<Box<dyn RefArg>>> = i.read().unwrap_or_default();
            let timeout: i32 = i.read().unwrap_or_default();

            let notification = NotificationMsg {
                appname,
                replaces_id,
                summary,
                body,
                actions,
                hints: hints.iter().map(|(k, _v)| k.clone()).collect(),
                icon,
                timeout,
                unread: true,
            };

            let noticheck = format!("{}{}", notification.appname.to_string(), notification.summary.to_string());
            let pmcheck = format!("{}{}", pm.appname.to_string(), pm.summary.to_string());

            if (current_ts - *ts).num_milliseconds() > 1000 || noticheck != pmcheck {
                debug!("message: {} | {} : {}", &notification.appname, &notification.summary, &notification.body);
                add_notification(&notification.appname, &notification.summary, &notification.body);
                *ts = current_ts;
                *pm = notification;
            }
            true
        }),
    );

    loop {
        conn.process(Duration::from_millis(1000)).unwrap_or_else(|_| {
            warn!("connection timed out");
            process::exit(1);
        });
    }
}

// --| Adds notification to database ------------
fn add_notification(sender: &str, title: &str, body: &str) {
    let connection = &mut establish_connection();
    let _ = insert_notification(connection, sender, Some(title), Some(body));
}

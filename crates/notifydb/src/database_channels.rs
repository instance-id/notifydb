use std::collections::HashMap;
use std::str::FromStr;

use log::debug;
use nativeshell::codec::value::from_value;
use nativeshell::{
    codec::{MethodCall, MethodCallReply, Value},
    shell::{Context, EngineHandle, MethodCallHandler, MethodChannel},
};

pub struct DatabaseChannels {
    context: Context,
}

impl DatabaseChannels {
    pub fn new(context: Context) -> Self {
        Self { context }
    }

    pub fn register(self) -> MethodChannel {
        MethodChannel::new(self.context.clone(), "database_channel", self)
    }
}

impl MethodCallHandler for DatabaseChannels {
    fn on_method_call(&mut self, call: MethodCall<Value>, reply: MethodCallReply<Value>, _engine: EngineHandle) {
        match call.method.as_str() {
            // --| Settings ---------------------
            "get_settings" => {
                let request: String = from_value(&call.args).unwrap();
                let settings_data = notifydblib::get_settings(&request);
                debug!("Settings data: {:?}", settings_data);

                reply.send_ok(nativeshell::codec::Value::String(settings_data));
            }

            "update_settings" => {
                let request: HashMap<String, String> = from_value(&call.args).unwrap();
                debug!("Settings update request: {:?}", &request);

                let app_name = request.get("app_name").unwrap().as_str();
                let settings = request.get("settings").unwrap().as_str();

                let result = notifydblib::upsert_settings(app_name, settings);
                reply.send_ok(nativeshell::codec::Value::String(result));
            }

            // --| Notifications ----------------
            "get_notification_count" => {
                let count_results = notifydblib::get_notification_count();
                debug!("Count results: {:?}", count_results);

                reply.send_ok(nativeshell::codec::Value::I64(count_results));
            }
            "query_database" => {
                let request: Vec<String> = from_value(&call.args).unwrap();
                let load_request = i64::from_str(request.get(1).unwrap().as_str()).unwrap();
                debug!("{:?}", call.args);
                let notification_results = notifydblib::get_notifications(load_request);

                reply.send_ok(nativeshell::codec::Value::String(notification_results));
            }
            "markSelected" => {
                let request: HashMap<String, Value> = from_value(&call.args).unwrap();

                let delete: bool = from_value(request.get("delete").unwrap()).unwrap();
                let selected_ids:Vec<i32> = from_value(request.get("selected").unwrap()).unwrap();
                let notification_results;

                if delete { notification_results = notifydblib::delete_notifications(selected_ids); }
                else { notification_results = notifydblib::mark_notifications_as_read(selected_ids); }

                reply.send_ok(nativeshell::codec::Value::String(notification_results));
            }
            _ => {}
        }
    }

    fn on_engine_destroyed(&mut self, _engine: EngineHandle) {}
}

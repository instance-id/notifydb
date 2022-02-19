use nativeshell::{
    codec::{MethodCall, MethodCallReply, Value},
    shell::{Context, EngineHandle, MethodCallHandler, MethodChannel},
};
use nativeshell::codec::value::from_value;

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
            "query_database" => {
                println!("{:?}", call.args);

                let notification_results = notifydblib::get_notifications();
                reply.send_ok(nativeshell::codec::Value::String(notification_results));
            }

            "markSelected" => {
                let request: Vec<i32> = from_value(&call.args).unwrap();

                let notification_results = notifydblib::mark_notifications_as_read(request);
                reply.send_ok(nativeshell::codec::Value::String(notification_results));
            }

            _ => {}
        }
    }

    fn on_engine_destroyed(&mut self, _engine: EngineHandle) {}
}

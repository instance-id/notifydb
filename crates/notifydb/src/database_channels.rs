use std::{thread, time::Duration};

use nativeshell::{
    codec::{MethodCall, MethodCallReply, Value},
    shell::{Context, EngineHandle, MethodCallHandler, MethodChannel},
    util::Capsule,
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
            "query_database" => {
                println!("{:?}",call.args);

                let notification_results = notifydblib::get_notifications();
                reply.send_ok(nativeshell::codec::Value::String(notification_results));
            }

            "echo" => {
                reply.send_ok(call.args);
            }
            "backgroundTask" => {
                // reply is not thread safe and can not be sent between threads directly;
                // use capsule to move it between threads
                let mut reply = Capsule::new(reply);

                let sender = self.context.get().unwrap().run_loop.borrow().new_sender();
                thread::spawn(move || {
                    // simulate long running task on background thread
                    thread::sleep(Duration::from_secs(4));
                    let value = 3.141592;
                    // jump back to platform thread to send the reply
                    sender.send(move || {
                        // capsule will only let us take the stored value on thread where
                        // it was created
                        let reply = reply.take().unwrap();
                        reply.send_ok(Value::F64(value));
                    });
                });
            }
            _ => {}
        }
    }

    // optionally you can get notifications when an engine gets destroyed, which
    // might be useful for clean-up
    fn on_engine_destroyed(&mut self, _engine: EngineHandle) {}
}

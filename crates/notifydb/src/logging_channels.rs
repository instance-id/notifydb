use log::{debug, warn, info, error};
use nativeshell::codec::value::from_value;
use nativeshell::{
    codec::{MethodCall, MethodCallReply, Value},
    shell::{Context, EngineHandle, MethodCallHandler, MethodChannel},
};

pub struct LoggingChannels {
    context: Context,
}

impl LoggingChannels {
    pub fn new(context: Context) -> Self {
        Self { context }
    }

    pub fn register(self) -> MethodChannel {
        MethodChannel::new(self.context.clone(), "logging_channel", self)
    }
}

impl MethodCallHandler for LoggingChannels {
    fn on_method_call(&mut self, call: MethodCall<Value>, reply: MethodCallReply<Value>, _engine: EngineHandle) {
        match call.method.as_str() {
            // --| Settings ---------------------
            "log_message" => {
                let request: String = from_value(&call.args).unwrap();
                match request.as_str() {
                    "debug" => debug!("{}", request),
                    "info" => info!("{}", request),
                    "warn" => warn!("{}", request),
                    "error" => error!("{}", request),
                    _ => debug!("{}", request),
                }

                reply.send_ok(nativeshell::codec::Value::String(String::from("Success")));
            }

            _ => {}
        }
    }

    fn on_engine_destroyed(&mut self, _engine: EngineHandle) {}
}

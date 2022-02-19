use log::*;
use notifydblib::*;
extern crate config;
extern crate serde_json;

use nativeshell::{
    codec::{MethodCall, MethodCallReply, Value},
    shell::{Context, EngineHandle, MethodCallHandler, MethodChannel},
};

pub struct SettingsChannels {
    context: Context,
}

impl SettingsChannels {
    pub fn new(context: Context) -> Self {
        Self { context }
    }

    pub fn register(self) -> MethodChannel {
        MethodChannel::new(self.context.clone(), "settings_channel", self)
    }
}

impl MethodCallHandler for SettingsChannels {
    fn on_method_call(&mut self, call: MethodCall<Value>, reply: MethodCallReply<Value>, _engine: EngineHandle) {
        match call.method.as_str() {
            "get_app_settings" => {
                debug!("{:?}", call.args);
                // let config = SETTINGS.read().unwrap().clone();
                // let s: String = config.try_into().unwrap();
                reply.send_ok(nativeshell::codec::Value::String(
                    SETTINGS.read().unwrap().clone().try_into::<serde_json::Value>().unwrap().to_string(),
                ));
            }
            _ => {}
        }
    }

    fn on_engine_destroyed(&mut self, _engine: EngineHandle) {}
}

#[cfg(test)]
mod test {
    use super::*;

    //     const TEST_CONFIG: &str = r#"
    // [viewer]

    // # --| Table Colors ----------
    // cellTextStyle='0xffD7D3CE'
    // gridBackgroundColor='0xff242424'
    // gridBorderColor='#000000'
    // activatedColor='#000000'
    // activatedBorderColor='#000000'
    // inactivatedBorderColor='#000000'
    // checkedColor='#000000'
    // borderColor='#000000'
    // cellColorInEditState='#000000'
    // cellColorInReadOnlyState='#000000'
    // "#;

    #[test]
    fn test_loading_config_string() {
        let s = SETTINGS.read().unwrap().clone().try_into::<serde_json::Value>().unwrap();
        debug!("config: {}", &s);

        // let s1 = s;
        // let json_string = serde_json::to_string(&s1).unwrap_or_else(|err| {
        //     debug!("Error serializing to json: {}", err);
        //     String::from("Not_found")
        // });

        // println!("json_string: {}", json_string);

        // println!("config: {}", &config.unwrap());

        // let end_str = r#"{'viewer':{'cellTextStyle':'0xffD7D3CE','gridBackgroundColor':'0xff242424','gridBorderColor':'#000000','activatedColor':'#000000','activatedBorderColor':'#000000','inactivatedBorderColor':'#000000','checkedColor':'#000000','borderColor':'#000000','cellColorInEditState':'#000000','cellColorInReadOnlyState':'#000000'}}"#.to_string();

        // assert_eq!(s, end_str);
    }
}

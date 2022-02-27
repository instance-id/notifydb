use log::debug;
use nativeshell::{
    codec::Value,
    shell::{exec_bundle, register_observatory_listener, Context, ContextOptions},
};
use logging_channels::LoggingChannels;
use settings_channels::SettingsChannels;
use database_channels::DatabaseChannels;

// use file_open_dialog::FileOpenDialog;
// use platform_channels::PlatformChannels;
// use window_channels::WindowChannels;

#[cfg(target_os = "macos")]
#[macro_use]
extern crate objc;

mod logging_channels;
mod settings_channels;
mod database_channels;

// mod file_open_dialog;
// mod platform_channels;
// mod window_channels;

nativeshell::include_flutter_plugins!();

fn main() -> () {
    exec_bundle();
    register_observatory_listener("notifydb".into());

    notifydblib::init_logging();
    debug!("Starting notifydb");

    let context = Context::new(ContextOptions {
        app_namespace: "notifydb".into(),
        flutter_plugins: flutter_get_plugins(),
        ..Default::default()
    });

    let context = context.unwrap();

    let _logging_channels = LoggingChannels::new(context.weak()).register();
    let _settings_channels = SettingsChannels::new(context.weak()).register();
    let _database_channels = DatabaseChannels::new(context.weak()).register();
    
    // let _file_open_dialog = FileOpenDialog::new(context.weak()).register();
    // let _platform_channels = PlatformChannels::new(context.weak()).register();
    // let _window_channels = WindowChannels::new(context.weak()).register();

    context.window_manager.borrow_mut().create_window(Value::Null, None).unwrap();
    context.run_loop.borrow().run();
}

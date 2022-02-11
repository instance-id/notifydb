use file_open_dialog::FileOpenDialog;
use nativeshell::{
    codec::Value,
    shell::{exec_bundle, register_observatory_listener, Context, ContextOptions},
};
use platform_channels::PlatformChannels;
use database_channels::DatabaseChannels;
use window_channels::WindowChannels;

#[cfg(target_os = "macos")]
#[macro_use]
extern crate objc;

mod file_open_dialog;
mod platform_channels;
mod database_channels;
mod window_channels;

nativeshell::include_flutter_plugins!();

fn main() -> () {
    exec_bundle();
    register_observatory_listener("notifydb".into());

    env_logger::builder().format_timestamp(None).init();

    let context = Context::new(ContextOptions {
        app_namespace: "notifydb".into(),
        flutter_plugins: flutter_get_plugins(),
        ..Default::default()
    });

    let context = context.unwrap();

    let _file_open_dialog = FileOpenDialog::new(context.weak()).register();
    let _platform_channels = PlatformChannels::new(context.weak()).register();
    let _database_channels = DatabaseChannels::new(context.weak()).register();
    let _window_channels = WindowChannels::new(context.weak()).register();

    context.window_manager.borrow_mut().create_window(Value::Null, None).unwrap();

    context.run_loop.borrow().run();
}

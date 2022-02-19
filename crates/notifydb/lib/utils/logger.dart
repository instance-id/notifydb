import '../main.dart';
import '../model/settings_data.dart';
import '../services/app_services.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

mixin Logger {
  static final Database settings = getIt.get<AppServices>().settings_data.database;
  static final LogLevel logLevel =
      LogLevel.values.firstWhere((LogLevel level) => level.toString().contains(settings.logLevel!.toLowerCase()) ?? false);

  static void debug(String message) {
    if (logLevel.index <= LogLevel.debug.index) {
      Future.microtask(() => print('** [DEBUG] $message'));
    }
  }

  static void info(String message) {
    if (logLevel.index <= LogLevel.info.index) {
      Future.microtask(() => print('** [INFO] $message'));
    }
  }

  static void error(String message) {
    if (logLevel.index <= LogLevel.error.index) {
      Future.microtask(() => print('** [ERROR] $message'));
    }
  }

  static void write(String text, {String level = 'INFO', bool isError = false}) {
    if (!settings.debug! && !isError) return;
    var messageString;
    if (isError) {
      messageString = '** [ERROR] $text';
    } else {
      messageString = '** [$level] $text';
    }
    Future.microtask(() => print(messageString));
  }
}

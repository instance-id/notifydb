import 'package:get/get.dart';

import '../controllers/data_controller.dart';
import '../controllers/logging_controller.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

mixin Logger {
  static LoggingController loggingController = Get.find<LoggingController>();

  static int checkLogLevel() {
    return LogLevel.values
        .firstWhere(
            (LogLevel level) => level.toString().contains(Get.find<DataController>().logLevel.toLowerCase() ?? 'error'))
        .index;
  }

  static void debug(String message) {
    if (checkLogLevel() <= LogLevel.debug.index) {
      Future.microtask(() => loggingController.log('** [DEBUG] $message'));
    }
  }

  static void info(String message) {
    if (checkLogLevel() <= LogLevel.info.index) {
      Future.microtask(() => loggingController.log('** [INFO] $message'));
    }
  }

  static void error(String message) {
    if (checkLogLevel() <= LogLevel.error.index) {
      Future.microtask(() => loggingController.log('** [ERROR] $message'));
    }
  }

  static void write(String text, {String level = 'INFO', bool isError = false}) {
    var messageString;
    if (isError) {
      messageString = '** [ERROR] $text';
    } else {
      messageString = '** [$level] $text';
    }

    Future.microtask(() => loggingController.log(messageString));
  }

  static void print(String text, {String level = 'INFO', bool isError = false}) {
    var messageString;
    if (isError) {
      messageString = '** [ERROR] $text';
    } else {
      messageString = '** [$level] $text';
    }

    Future.microtask(() => print(messageString));
  }
}

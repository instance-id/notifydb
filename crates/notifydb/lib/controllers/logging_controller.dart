import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoggingController extends GetxController {
  final _logChannel = MethodChannel('logging_channel');

  void log(String message) {
    _logChannel.invokeMethod('log_message', message);
  }
}

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notifydb/utils/logger.dart';

class CategoryController extends GetxController {
  final _channel = MethodChannel('example_channel');

  var count = 0.obs;

  increment() => count++;

  void close() async {
    final value = await _channel.invokeMethod('echo', 'Hello');
    Logger.write(value);
  }
}

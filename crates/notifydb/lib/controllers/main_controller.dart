// ignore_for_file: always_declare_return_types

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notifydb/utils/logger.dart';

class MainController extends GetxController {
  final _channel = MethodChannel('main_app');

  var appInitialSize = Size(1000,550);
  var debug = true.obs;

  var menuIndex = 0.obs;
  get mainIndex => menuIndex.toInt();

  bool isDebug() { return debug.value; }
  void setDebug(bool value) { debug.value = value; }

  selectIndex(int s) {
    mainIndex.update((value) { value = s; });
    Logger.debug(mainIndex.toString());
  }

  void close() async {
    final value = await _channel.invokeMethod('echo', 'Hello');
    Logger.debug(value);
  }
}

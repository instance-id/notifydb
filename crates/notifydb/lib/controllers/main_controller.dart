import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notifydb/utils/logger.dart';

class MainController extends GetxController {
  final _channel = MethodChannel('main_app');

  var menuIndex = 0.obs;
  get mainIndex => menuIndex.toInt();

  selectIndex(int s) {
    mainIndex.update((value) {
      value = s;
    });

    Logger.write(mainIndex.toString());
  }

  void close() async {
    final value = await _channel.invokeMethod('echo', 'Hello');
    Logger.write(value);
  }
}

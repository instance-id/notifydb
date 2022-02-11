import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Controller extends GetxController{

  final _channel = MethodChannel('window_channel');


  var count = 0.obs;
  increment() => count++;


  void close() async {
    final _ = await _channel.invokeMethod('echo', 'Hello');
  }

}

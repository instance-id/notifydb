import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nativeshell/nativeshell.dart';

import '../home/notification_model.dart' as notifi;
import '../main.dart';
import '../utils/logger.dart';

abstract class AppServices extends ChangeNotifier {
  void incrementCounter();
  void getNotifications();
  int get counter;
  List<notifi.Notification> get notification_list;
  Geometry get size;
}

class AppServicesImpl extends AppServices {
  final _channel = MethodChannel('database_channel');
  int _counter = 0;
  final Geometry _size = Geometry(frameSize: Size(800, 450), contentSize: Size(800, 450));
  List<notifi.Notification> _notification_list = <notifi.Notification>[];

  AppServicesImpl() {
    var notifyData = getData('all');
    Logger.write(notifyData.then((value) => value).toString());
    notifyData.then((notificationList) => _notification_list = notificationList).then((_) => getIt.signalReady(this));
  }

  Future getData(String query) async {
    switch (query) {
      case 'one':
        final value = await _channel.invokeMethod('query_database', query);
        var val2 = value.substring(1, value.length - 1);
        Logger.write('val2: ' + val2.toString());
        var jsonObject = convert.jsonDecode(val2);
        var result = notifi.Notification.fromJson(jsonObject);
        Logger.write('result: ' + result.appname.toString());
        Logger.write('result: ' + result.created_at.toString());
        return result;

      case 'all':
        final value = await _channel.invokeMethod('query_database', query);
        var jsonObject = convert.jsonDecode(value) as List;
        var result = jsonObject.map((notification) => notifi.Notification.fromJson(notification)).toList();
        Logger.write('result: ' + result[0].appname.toString());
        Logger.write('result: ' + result[0].created_at.toString());
        return result;
      default:
    }
  }

  @override
  int get counter => _counter;

  @override
  Geometry get size => _size;

  @override
  List<notifi.Notification> get notification_list => _notification_list;

  @override
  List<notifi.Notification> getNotifications() {
    return notification_list;
  }

  @override
  void incrementCounter() {
    _counter++;
    notifyListeners();
  }
}

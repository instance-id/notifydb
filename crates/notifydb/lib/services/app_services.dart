import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nativeshell/nativeshell.dart';

import '../model/settings_data.dart';
import '../models/notification_model.dart' as notifi;
import '../main.dart';

abstract class AppServices extends ChangeNotifier {
  void getNotifications();
  List<notifi.Notification> get notification_list;
  Geometry get size;
  SettingsData get settings_data;
  void setNotificationList(List<notifi.Notification> value);
}

class AppServicesImpl extends AppServices {
  // --| Backend Service Channels --------------------
  // --|----------------------------------------------
  final _channel = MethodChannel('database_channel');
  final _schannel = MethodChannel('settings_channel');

  late SettingsData _settings_data;
  List<notifi.Notification> _notification_list = <notifi.Notification>[];

  final Geometry _size = Geometry(frameSize: Size(1000, 550), contentSize: Size(1000, 550));

  // --| AppServices Implementation Constructor ------
  AppServicesImpl() {
    var settings = getSettings('viewer');
    settings.then((value) {
      _settings_data = value;
      notifyListeners();
    });

    var notifyData = getData('all');

    notifyData.then((value) {
      _notification_list = value;
      notifyListeners();
      getIt.signalReady(this);
    });
  }

  @override
  void setNotificationList(List<notifi.Notification> value) {
    _notification_list = value;
    notifyListeners();
  }

  // --| Get App Settings --------------------------------------
  // --|--------------------------------------------------------
  Future<SettingsData> getSettings(String arguments) async {
    final settings = await _schannel.invokeMethod('get_app_settings', arguments);
    return settingsDataFromJson(settings);
  }

  // --| Get Notification Data ---------------------------------
  // --|--------------------------------------------------------
  Future getData(String query) async {
    switch (query) {
      case 'one':
        final value = await _channel.invokeMethod('query_database', query);
        var val2 = value.substring(1, value.length - 1);

        var jsonObject = convert.jsonDecode(val2);
        var result = notifi.Notification.fromJson(jsonObject);
        return result;

      case 'all':
        final value = await _channel.invokeMethod('query_database', query);
        var jsonObject = convert.jsonDecode(value) as List;
        var result = jsonObject.map((notification) => notifi.Notification.fromJson(notification)).toList();

        return result;
      default:
    }
  }

  @override
  Geometry get size => _size;

  @override
  List<notifi.Notification> get notification_list => _notification_list;


  @override
  List<notifi.Notification> getNotifications() {
    return notification_list;
  }

  @override
  SettingsData get settings_data => _settings_data;
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: unused_import
import '../utils/logger.dart';

class Notification {
  final String id;
  final String? appname;
  final String? replaces_id;
  final String? summary;
  final String? body;
  final String? actions;
  final String? hints;
  final String? icon;
  final String? timeout;
  final String? created_at;

  String get Created_at => modifyDate(created_at!);

  // set created_at => modifyDate(created_at!);

  IconData? iconData;

  String modifyDate(String date) {
    var dateTime = DateTime.parse(date);
    return DateFormat('MM-dd-yyyy HH:mm:ss').format(dateTime.add(DateTime.parse(date).timeZoneOffset)).toString();
  }

  Notification(
      {required this.id,
      this.appname,
      this.replaces_id,
      this.summary,
      this.body,
      this.actions,
      this.hints,
      this.icon,
      this.timeout,
      this.created_at});

  Notification.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'].toString(),
        appname = parsedJson['sender'],
        replaces_id = parsedJson['replaces_id'],
        summary = parsedJson['title'],
        body = parsedJson['body'],
        actions = parsedJson['actions'],
        hints = parsedJson['hints'],
        icon = parsedJson['icon'],
        timeout = parsedJson['timeout'],
        created_at = parsedJson['created_at'];
}

import 'package:flutter/material.dart';

class NotificationData {
  final String id;
  final String? appname;
  final String? replaces_id;
  final String? summary;
  final String? body;
  final String? actions;
  final String? hints;
  final String? icon;
  final String? timeout;

  IconData? iconData;

  NotificationData({
    required this.id,
    this.appname,
    this.replaces_id,
    this.summary,
    this.body,
    this.actions,
    this.hints,
    this.icon,
    this.timeout,
  });

  NotificationData.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'].toString(),
        appname = parsedJson['appname'],
        replaces_id = parsedJson['replaces_id'],
        summary = parsedJson['summary'],
        body = parsedJson['body'],
        actions = parsedJson['actions'],
        hints = parsedJson['hints'],
        icon = parsedJson['icon'],
        timeout = parsedJson['timeout'];
}

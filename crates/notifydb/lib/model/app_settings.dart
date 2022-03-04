

// ignore_for_file: unused_import
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

AppSettings appSettingsFromJson(String str) => AppSettings.fromJson(json.decode(str));
String appSettingsToJson(AppSettings data) => json.encode(data.toJson());

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('notifydb')  @JsonKey(name: 'appName') String? appName,
    @JsonKey(name: 'settings') required Settings settings,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}

@freezed
class Settings with _$Settings {
  const factory Settings({
    @Default('true') String? animations,
    @Default('true') String? autoRefresh,
    @Default(3) int? autoRefreshInterval,
    @Default('false') String? refreshOnMarkAsRead,
    @Default('error') String? logLevel,
    @Default(1000) int? maxLoadedMessages,
    @Default(50) int? maxPerPage,
    @Default('true') String? deleteReadMessages,
    @Default('') String? windowSize,
  }) = _Settings;


  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
}

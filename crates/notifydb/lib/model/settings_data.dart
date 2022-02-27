// To parse this JSON data, do
//
//     final settingsData = settingsDataFromJson(jsonString);

// ignore_for_file: unused_import

import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'settings_data.freezed.dart';
part 'settings_data.g.dart';

SettingsData settingsDataFromJson(String str) => SettingsData.fromJson(json.decode(str));

String settingsDataToJson(SettingsData data) => json.encode(data.toJson());

@freezed
class SettingsData with _$SettingsData {
  const factory SettingsData({
    required Database database,
    required Viewer viewer,
  }) = _SettingsData;

  factory SettingsData.fromJson(Map<String, dynamic> json) => _$SettingsDataFromJson(json);
}

@freezed
class Database with _$Database {
  const factory Database({
    @Default('warning') String? logLevel,
    @Default(false) bool? debug,
  }) = _Database;

  factory Database.fromJson(Map<String, dynamic> json) => _$DatabaseFromJson(json);
}

@freezed
class Viewer with _$Viewer {
  const factory Viewer({
    @Default('#303030') String? activatedBorderColor,
    @Default('#303030') String? activatedColor,
    @Default('#303030') String? borderColor,
    @Default('#303030') String? cellColorInEditState,
    @Default('#303030') String? cellColorInReadOnlyState,
    @Default('#303030') String? cellTextStyle,
    @Default('#303030') String? checkedColor,
    @Default('#313131') String? footerBackgroundColor,
    @Default('#303030') String? gridBackgroundColor,
    @Default('#363636') String? gridBorderColor,
    @Default('#D7D3CE') String? headerBackgroundColor,
    @Default('#303030') String? inactivatedBorderColor,
    @Default('#4d8bff4d') String? selectedRowColor,
    @Default('#212121') String? tableOuterBackgroundColor,
  }) = _Viewer;

  factory Viewer.fromJson(Map<String, dynamic> json) => _$ViewerFromJson(json);
}

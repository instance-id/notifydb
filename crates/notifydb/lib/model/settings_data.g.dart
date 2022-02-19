// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SettingsData _$$_SettingsDataFromJson(Map<String, dynamic> json) =>
    _$_SettingsData(
      database: Database.fromJson(json['database'] as Map<String, dynamic>),
      viewer: Viewer.fromJson(json['viewer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_SettingsDataToJson(_$_SettingsData instance) =>
    <String, dynamic>{
      'database': instance.database,
      'viewer': instance.viewer,
    };

_$_Database _$$_DatabaseFromJson(Map<String, dynamic> json) => _$_Database(
      databaseUrl: json['databaseUrl'] as String,
      logLevel: json['logLevel'] as String? ?? 'warning',
      debug: json['debug'] as bool? ?? false,
    );

Map<String, dynamic> _$$_DatabaseToJson(_$_Database instance) =>
    <String, dynamic>{
      'databaseUrl': instance.databaseUrl,
      'logLevel': instance.logLevel,
      'debug': instance.debug,
    };

_$_Viewer _$$_ViewerFromJson(Map<String, dynamic> json) => _$_Viewer(
      activatedBorderColor:
          json['activatedBorderColor'] as String? ?? '#303030',
      activatedColor: json['activatedColor'] as String? ?? '#303030',
      borderColor: json['borderColor'] as String? ?? '#303030',
      cellColorInEditState:
          json['cellColorInEditState'] as String? ?? '#303030',
      cellColorInReadOnlyState:
          json['cellColorInReadOnlyState'] as String? ?? '#303030',
      cellTextStyle: json['cellTextStyle'] as String? ?? '#303030',
      checkedColor: json['checkedColor'] as String? ?? '#303030',
      footerBackgroundColor:
          json['footerBackgroundColor'] as String? ?? '#313131',
      gridBackgroundColor: json['gridBackgroundColor'] as String? ?? '#303030',
      gridBorderColor: json['gridBorderColor'] as String? ?? '#363636',
      headerBackgroundColor:
          json['headerBackgroundColor'] as String? ?? '#D7D3CE',
      inactivatedBorderColor:
          json['inactivatedBorderColor'] as String? ?? '#303030',
      selectedRowColor: json['selectedRowColor'] as String? ?? '#4d8bff4d',
      tableOuterBackgroundColor:
          json['tableOuterBackgroundColor'] as String? ?? '#212121',
    );

Map<String, dynamic> _$$_ViewerToJson(_$_Viewer instance) => <String, dynamic>{
      'activatedBorderColor': instance.activatedBorderColor,
      'activatedColor': instance.activatedColor,
      'borderColor': instance.borderColor,
      'cellColorInEditState': instance.cellColorInEditState,
      'cellColorInReadOnlyState': instance.cellColorInReadOnlyState,
      'cellTextStyle': instance.cellTextStyle,
      'checkedColor': instance.checkedColor,
      'footerBackgroundColor': instance.footerBackgroundColor,
      'gridBackgroundColor': instance.gridBackgroundColor,
      'gridBorderColor': instance.gridBorderColor,
      'headerBackgroundColor': instance.headerBackgroundColor,
      'inactivatedBorderColor': instance.inactivatedBorderColor,
      'selectedRowColor': instance.selectedRowColor,
      'tableOuterBackgroundColor': instance.tableOuterBackgroundColor,
    };

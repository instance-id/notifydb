// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'settings_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SettingsData _$SettingsDataFromJson(Map<String, dynamic> json) {
  return _SettingsData.fromJson(json);
}

/// @nodoc
class _$SettingsDataTearOff {
  const _$SettingsDataTearOff();

  _SettingsData call({required Database database, required Viewer viewer}) {
    return _SettingsData(
      database: database,
      viewer: viewer,
    );
  }

  SettingsData fromJson(Map<String, Object?> json) {
    return SettingsData.fromJson(json);
  }
}

/// @nodoc
const $SettingsData = _$SettingsDataTearOff();

/// @nodoc
mixin _$SettingsData {
  Database get database => throw _privateConstructorUsedError;
  Viewer get viewer => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettingsDataCopyWith<SettingsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsDataCopyWith<$Res> {
  factory $SettingsDataCopyWith(
          SettingsData value, $Res Function(SettingsData) then) =
      _$SettingsDataCopyWithImpl<$Res>;
  $Res call({Database database, Viewer viewer});

  $DatabaseCopyWith<$Res> get database;
  $ViewerCopyWith<$Res> get viewer;
}

/// @nodoc
class _$SettingsDataCopyWithImpl<$Res> implements $SettingsDataCopyWith<$Res> {
  _$SettingsDataCopyWithImpl(this._value, this._then);

  final SettingsData _value;
  // ignore: unused_field
  final $Res Function(SettingsData) _then;

  @override
  $Res call({
    Object? database = freezed,
    Object? viewer = freezed,
  }) {
    return _then(_value.copyWith(
      database: database == freezed
          ? _value.database
          : database // ignore: cast_nullable_to_non_nullable
              as Database,
      viewer: viewer == freezed
          ? _value.viewer
          : viewer // ignore: cast_nullable_to_non_nullable
              as Viewer,
    ));
  }

  @override
  $DatabaseCopyWith<$Res> get database {
    return $DatabaseCopyWith<$Res>(_value.database, (value) {
      return _then(_value.copyWith(database: value));
    });
  }

  @override
  $ViewerCopyWith<$Res> get viewer {
    return $ViewerCopyWith<$Res>(_value.viewer, (value) {
      return _then(_value.copyWith(viewer: value));
    });
  }
}

/// @nodoc
abstract class _$SettingsDataCopyWith<$Res>
    implements $SettingsDataCopyWith<$Res> {
  factory _$SettingsDataCopyWith(
          _SettingsData value, $Res Function(_SettingsData) then) =
      __$SettingsDataCopyWithImpl<$Res>;
  @override
  $Res call({Database database, Viewer viewer});

  @override
  $DatabaseCopyWith<$Res> get database;
  @override
  $ViewerCopyWith<$Res> get viewer;
}

/// @nodoc
class __$SettingsDataCopyWithImpl<$Res> extends _$SettingsDataCopyWithImpl<$Res>
    implements _$SettingsDataCopyWith<$Res> {
  __$SettingsDataCopyWithImpl(
      _SettingsData _value, $Res Function(_SettingsData) _then)
      : super(_value, (v) => _then(v as _SettingsData));

  @override
  _SettingsData get _value => super._value as _SettingsData;

  @override
  $Res call({
    Object? database = freezed,
    Object? viewer = freezed,
  }) {
    return _then(_SettingsData(
      database: database == freezed
          ? _value.database
          : database // ignore: cast_nullable_to_non_nullable
              as Database,
      viewer: viewer == freezed
          ? _value.viewer
          : viewer // ignore: cast_nullable_to_non_nullable
              as Viewer,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SettingsData with DiagnosticableTreeMixin implements _SettingsData {
  const _$_SettingsData({required this.database, required this.viewer});

  factory _$_SettingsData.fromJson(Map<String, dynamic> json) =>
      _$$_SettingsDataFromJson(json);

  @override
  final Database database;
  @override
  final Viewer viewer;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SettingsData(database: $database, viewer: $viewer)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SettingsData'))
      ..add(DiagnosticsProperty('database', database))
      ..add(DiagnosticsProperty('viewer', viewer));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingsData &&
            const DeepCollectionEquality().equals(other.database, database) &&
            const DeepCollectionEquality().equals(other.viewer, viewer));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(database),
      const DeepCollectionEquality().hash(viewer));

  @JsonKey(ignore: true)
  @override
  _$SettingsDataCopyWith<_SettingsData> get copyWith =>
      __$SettingsDataCopyWithImpl<_SettingsData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SettingsDataToJson(this);
  }
}

abstract class _SettingsData implements SettingsData {
  const factory _SettingsData(
      {required Database database, required Viewer viewer}) = _$_SettingsData;

  factory _SettingsData.fromJson(Map<String, dynamic> json) =
      _$_SettingsData.fromJson;

  @override
  Database get database;
  @override
  Viewer get viewer;
  @override
  @JsonKey(ignore: true)
  _$SettingsDataCopyWith<_SettingsData> get copyWith =>
      throw _privateConstructorUsedError;
}

Database _$DatabaseFromJson(Map<String, dynamic> json) {
  return _Database.fromJson(json);
}

/// @nodoc
class _$DatabaseTearOff {
  const _$DatabaseTearOff();

  _Database call(
      {required String databaseUrl,
      String? logLevel = 'warning',
      bool? debug = false}) {
    return _Database(
      databaseUrl: databaseUrl,
      logLevel: logLevel,
      debug: debug,
    );
  }

  Database fromJson(Map<String, Object?> json) {
    return Database.fromJson(json);
  }
}

/// @nodoc
const $Database = _$DatabaseTearOff();

/// @nodoc
mixin _$Database {
  String get databaseUrl => throw _privateConstructorUsedError;
  String? get logLevel => throw _privateConstructorUsedError;
  bool? get debug => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DatabaseCopyWith<Database> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DatabaseCopyWith<$Res> {
  factory $DatabaseCopyWith(Database value, $Res Function(Database) then) =
      _$DatabaseCopyWithImpl<$Res>;
  $Res call({String databaseUrl, String? logLevel, bool? debug});
}

/// @nodoc
class _$DatabaseCopyWithImpl<$Res> implements $DatabaseCopyWith<$Res> {
  _$DatabaseCopyWithImpl(this._value, this._then);

  final Database _value;
  // ignore: unused_field
  final $Res Function(Database) _then;

  @override
  $Res call({
    Object? databaseUrl = freezed,
    Object? logLevel = freezed,
    Object? debug = freezed,
  }) {
    return _then(_value.copyWith(
      databaseUrl: databaseUrl == freezed
          ? _value.databaseUrl
          : databaseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      logLevel: logLevel == freezed
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      debug: debug == freezed
          ? _value.debug
          : debug // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
abstract class _$DatabaseCopyWith<$Res> implements $DatabaseCopyWith<$Res> {
  factory _$DatabaseCopyWith(_Database value, $Res Function(_Database) then) =
      __$DatabaseCopyWithImpl<$Res>;
  @override
  $Res call({String databaseUrl, String? logLevel, bool? debug});
}

/// @nodoc
class __$DatabaseCopyWithImpl<$Res> extends _$DatabaseCopyWithImpl<$Res>
    implements _$DatabaseCopyWith<$Res> {
  __$DatabaseCopyWithImpl(_Database _value, $Res Function(_Database) _then)
      : super(_value, (v) => _then(v as _Database));

  @override
  _Database get _value => super._value as _Database;

  @override
  $Res call({
    Object? databaseUrl = freezed,
    Object? logLevel = freezed,
    Object? debug = freezed,
  }) {
    return _then(_Database(
      databaseUrl: databaseUrl == freezed
          ? _value.databaseUrl
          : databaseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      logLevel: logLevel == freezed
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      debug: debug == freezed
          ? _value.debug
          : debug // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Database with DiagnosticableTreeMixin implements _Database {
  const _$_Database(
      {required this.databaseUrl,
      this.logLevel = 'warning',
      this.debug = false});

  factory _$_Database.fromJson(Map<String, dynamic> json) =>
      _$$_DatabaseFromJson(json);

  @override
  final String databaseUrl;
  @JsonKey()
  @override
  final String? logLevel;
  @JsonKey()
  @override
  final bool? debug;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Database(databaseUrl: $databaseUrl, logLevel: $logLevel, debug: $debug)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Database'))
      ..add(DiagnosticsProperty('databaseUrl', databaseUrl))
      ..add(DiagnosticsProperty('logLevel', logLevel))
      ..add(DiagnosticsProperty('debug', debug));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Database &&
            const DeepCollectionEquality()
                .equals(other.databaseUrl, databaseUrl) &&
            const DeepCollectionEquality().equals(other.logLevel, logLevel) &&
            const DeepCollectionEquality().equals(other.debug, debug));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(databaseUrl),
      const DeepCollectionEquality().hash(logLevel),
      const DeepCollectionEquality().hash(debug));

  @JsonKey(ignore: true)
  @override
  _$DatabaseCopyWith<_Database> get copyWith =>
      __$DatabaseCopyWithImpl<_Database>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DatabaseToJson(this);
  }
}

abstract class _Database implements Database {
  const factory _Database(
      {required String databaseUrl,
      String? logLevel,
      bool? debug}) = _$_Database;

  factory _Database.fromJson(Map<String, dynamic> json) = _$_Database.fromJson;

  @override
  String get databaseUrl;
  @override
  String? get logLevel;
  @override
  bool? get debug;
  @override
  @JsonKey(ignore: true)
  _$DatabaseCopyWith<_Database> get copyWith =>
      throw _privateConstructorUsedError;
}

Viewer _$ViewerFromJson(Map<String, dynamic> json) {
  return _Viewer.fromJson(json);
}

/// @nodoc
class _$ViewerTearOff {
  const _$ViewerTearOff();

  _Viewer call(
      {String? activatedBorderColor = '#303030',
      String? activatedColor = '#303030',
      String? borderColor = '#303030',
      String? cellColorInEditState = '#303030',
      String? cellColorInReadOnlyState = '#303030',
      String? cellTextStyle = '#303030',
      String? checkedColor = '#303030',
      String? footerBackgroundColor = '#313131',
      String? gridBackgroundColor = '#303030',
      String? gridBorderColor = '#363636',
      String? headerBackgroundColor = '#D7D3CE',
      String? inactivatedBorderColor = '#303030',
      String? selectedRowColor = '#4d8bff4d',
      String? tableOuterBackgroundColor = '#212121'}) {
    return _Viewer(
      activatedBorderColor: activatedBorderColor,
      activatedColor: activatedColor,
      borderColor: borderColor,
      cellColorInEditState: cellColorInEditState,
      cellColorInReadOnlyState: cellColorInReadOnlyState,
      cellTextStyle: cellTextStyle,
      checkedColor: checkedColor,
      footerBackgroundColor: footerBackgroundColor,
      gridBackgroundColor: gridBackgroundColor,
      gridBorderColor: gridBorderColor,
      headerBackgroundColor: headerBackgroundColor,
      inactivatedBorderColor: inactivatedBorderColor,
      selectedRowColor: selectedRowColor,
      tableOuterBackgroundColor: tableOuterBackgroundColor,
    );
  }

  Viewer fromJson(Map<String, Object?> json) {
    return Viewer.fromJson(json);
  }
}

/// @nodoc
const $Viewer = _$ViewerTearOff();

/// @nodoc
mixin _$Viewer {
  String? get activatedBorderColor => throw _privateConstructorUsedError;
  String? get activatedColor => throw _privateConstructorUsedError;
  String? get borderColor => throw _privateConstructorUsedError;
  String? get cellColorInEditState => throw _privateConstructorUsedError;
  String? get cellColorInReadOnlyState => throw _privateConstructorUsedError;
  String? get cellTextStyle => throw _privateConstructorUsedError;
  String? get checkedColor => throw _privateConstructorUsedError;
  String? get footerBackgroundColor => throw _privateConstructorUsedError;
  String? get gridBackgroundColor => throw _privateConstructorUsedError;
  String? get gridBorderColor => throw _privateConstructorUsedError;
  String? get headerBackgroundColor => throw _privateConstructorUsedError;
  String? get inactivatedBorderColor => throw _privateConstructorUsedError;
  String? get selectedRowColor => throw _privateConstructorUsedError;
  String? get tableOuterBackgroundColor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ViewerCopyWith<Viewer> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewerCopyWith<$Res> {
  factory $ViewerCopyWith(Viewer value, $Res Function(Viewer) then) =
      _$ViewerCopyWithImpl<$Res>;
  $Res call(
      {String? activatedBorderColor,
      String? activatedColor,
      String? borderColor,
      String? cellColorInEditState,
      String? cellColorInReadOnlyState,
      String? cellTextStyle,
      String? checkedColor,
      String? footerBackgroundColor,
      String? gridBackgroundColor,
      String? gridBorderColor,
      String? headerBackgroundColor,
      String? inactivatedBorderColor,
      String? selectedRowColor,
      String? tableOuterBackgroundColor});
}

/// @nodoc
class _$ViewerCopyWithImpl<$Res> implements $ViewerCopyWith<$Res> {
  _$ViewerCopyWithImpl(this._value, this._then);

  final Viewer _value;
  // ignore: unused_field
  final $Res Function(Viewer) _then;

  @override
  $Res call({
    Object? activatedBorderColor = freezed,
    Object? activatedColor = freezed,
    Object? borderColor = freezed,
    Object? cellColorInEditState = freezed,
    Object? cellColorInReadOnlyState = freezed,
    Object? cellTextStyle = freezed,
    Object? checkedColor = freezed,
    Object? footerBackgroundColor = freezed,
    Object? gridBackgroundColor = freezed,
    Object? gridBorderColor = freezed,
    Object? headerBackgroundColor = freezed,
    Object? inactivatedBorderColor = freezed,
    Object? selectedRowColor = freezed,
    Object? tableOuterBackgroundColor = freezed,
  }) {
    return _then(_value.copyWith(
      activatedBorderColor: activatedBorderColor == freezed
          ? _value.activatedBorderColor
          : activatedBorderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      activatedColor: activatedColor == freezed
          ? _value.activatedColor
          : activatedColor // ignore: cast_nullable_to_non_nullable
              as String?,
      borderColor: borderColor == freezed
          ? _value.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      cellColorInEditState: cellColorInEditState == freezed
          ? _value.cellColorInEditState
          : cellColorInEditState // ignore: cast_nullable_to_non_nullable
              as String?,
      cellColorInReadOnlyState: cellColorInReadOnlyState == freezed
          ? _value.cellColorInReadOnlyState
          : cellColorInReadOnlyState // ignore: cast_nullable_to_non_nullable
              as String?,
      cellTextStyle: cellTextStyle == freezed
          ? _value.cellTextStyle
          : cellTextStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      checkedColor: checkedColor == freezed
          ? _value.checkedColor
          : checkedColor // ignore: cast_nullable_to_non_nullable
              as String?,
      footerBackgroundColor: footerBackgroundColor == freezed
          ? _value.footerBackgroundColor
          : footerBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      gridBackgroundColor: gridBackgroundColor == freezed
          ? _value.gridBackgroundColor
          : gridBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      gridBorderColor: gridBorderColor == freezed
          ? _value.gridBorderColor
          : gridBorderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      headerBackgroundColor: headerBackgroundColor == freezed
          ? _value.headerBackgroundColor
          : headerBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      inactivatedBorderColor: inactivatedBorderColor == freezed
          ? _value.inactivatedBorderColor
          : inactivatedBorderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedRowColor: selectedRowColor == freezed
          ? _value.selectedRowColor
          : selectedRowColor // ignore: cast_nullable_to_non_nullable
              as String?,
      tableOuterBackgroundColor: tableOuterBackgroundColor == freezed
          ? _value.tableOuterBackgroundColor
          : tableOuterBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$ViewerCopyWith<$Res> implements $ViewerCopyWith<$Res> {
  factory _$ViewerCopyWith(_Viewer value, $Res Function(_Viewer) then) =
      __$ViewerCopyWithImpl<$Res>;
  @override
  $Res call(
      {String? activatedBorderColor,
      String? activatedColor,
      String? borderColor,
      String? cellColorInEditState,
      String? cellColorInReadOnlyState,
      String? cellTextStyle,
      String? checkedColor,
      String? footerBackgroundColor,
      String? gridBackgroundColor,
      String? gridBorderColor,
      String? headerBackgroundColor,
      String? inactivatedBorderColor,
      String? selectedRowColor,
      String? tableOuterBackgroundColor});
}

/// @nodoc
class __$ViewerCopyWithImpl<$Res> extends _$ViewerCopyWithImpl<$Res>
    implements _$ViewerCopyWith<$Res> {
  __$ViewerCopyWithImpl(_Viewer _value, $Res Function(_Viewer) _then)
      : super(_value, (v) => _then(v as _Viewer));

  @override
  _Viewer get _value => super._value as _Viewer;

  @override
  $Res call({
    Object? activatedBorderColor = freezed,
    Object? activatedColor = freezed,
    Object? borderColor = freezed,
    Object? cellColorInEditState = freezed,
    Object? cellColorInReadOnlyState = freezed,
    Object? cellTextStyle = freezed,
    Object? checkedColor = freezed,
    Object? footerBackgroundColor = freezed,
    Object? gridBackgroundColor = freezed,
    Object? gridBorderColor = freezed,
    Object? headerBackgroundColor = freezed,
    Object? inactivatedBorderColor = freezed,
    Object? selectedRowColor = freezed,
    Object? tableOuterBackgroundColor = freezed,
  }) {
    return _then(_Viewer(
      activatedBorderColor: activatedBorderColor == freezed
          ? _value.activatedBorderColor
          : activatedBorderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      activatedColor: activatedColor == freezed
          ? _value.activatedColor
          : activatedColor // ignore: cast_nullable_to_non_nullable
              as String?,
      borderColor: borderColor == freezed
          ? _value.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      cellColorInEditState: cellColorInEditState == freezed
          ? _value.cellColorInEditState
          : cellColorInEditState // ignore: cast_nullable_to_non_nullable
              as String?,
      cellColorInReadOnlyState: cellColorInReadOnlyState == freezed
          ? _value.cellColorInReadOnlyState
          : cellColorInReadOnlyState // ignore: cast_nullable_to_non_nullable
              as String?,
      cellTextStyle: cellTextStyle == freezed
          ? _value.cellTextStyle
          : cellTextStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      checkedColor: checkedColor == freezed
          ? _value.checkedColor
          : checkedColor // ignore: cast_nullable_to_non_nullable
              as String?,
      footerBackgroundColor: footerBackgroundColor == freezed
          ? _value.footerBackgroundColor
          : footerBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      gridBackgroundColor: gridBackgroundColor == freezed
          ? _value.gridBackgroundColor
          : gridBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      gridBorderColor: gridBorderColor == freezed
          ? _value.gridBorderColor
          : gridBorderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      headerBackgroundColor: headerBackgroundColor == freezed
          ? _value.headerBackgroundColor
          : headerBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      inactivatedBorderColor: inactivatedBorderColor == freezed
          ? _value.inactivatedBorderColor
          : inactivatedBorderColor // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedRowColor: selectedRowColor == freezed
          ? _value.selectedRowColor
          : selectedRowColor // ignore: cast_nullable_to_non_nullable
              as String?,
      tableOuterBackgroundColor: tableOuterBackgroundColor == freezed
          ? _value.tableOuterBackgroundColor
          : tableOuterBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Viewer with DiagnosticableTreeMixin implements _Viewer {
  const _$_Viewer(
      {this.activatedBorderColor = '#303030',
      this.activatedColor = '#303030',
      this.borderColor = '#303030',
      this.cellColorInEditState = '#303030',
      this.cellColorInReadOnlyState = '#303030',
      this.cellTextStyle = '#303030',
      this.checkedColor = '#303030',
      this.footerBackgroundColor = '#313131',
      this.gridBackgroundColor = '#303030',
      this.gridBorderColor = '#363636',
      this.headerBackgroundColor = '#D7D3CE',
      this.inactivatedBorderColor = '#303030',
      this.selectedRowColor = '#4d8bff4d',
      this.tableOuterBackgroundColor = '#212121'});

  factory _$_Viewer.fromJson(Map<String, dynamic> json) =>
      _$$_ViewerFromJson(json);

  @JsonKey()
  @override
  final String? activatedBorderColor;
  @JsonKey()
  @override
  final String? activatedColor;
  @JsonKey()
  @override
  final String? borderColor;
  @JsonKey()
  @override
  final String? cellColorInEditState;
  @JsonKey()
  @override
  final String? cellColorInReadOnlyState;
  @JsonKey()
  @override
  final String? cellTextStyle;
  @JsonKey()
  @override
  final String? checkedColor;
  @JsonKey()
  @override
  final String? footerBackgroundColor;
  @JsonKey()
  @override
  final String? gridBackgroundColor;
  @JsonKey()
  @override
  final String? gridBorderColor;
  @JsonKey()
  @override
  final String? headerBackgroundColor;
  @JsonKey()
  @override
  final String? inactivatedBorderColor;
  @JsonKey()
  @override
  final String? selectedRowColor;
  @JsonKey()
  @override
  final String? tableOuterBackgroundColor;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Viewer(activatedBorderColor: $activatedBorderColor, activatedColor: $activatedColor, borderColor: $borderColor, cellColorInEditState: $cellColorInEditState, cellColorInReadOnlyState: $cellColorInReadOnlyState, cellTextStyle: $cellTextStyle, checkedColor: $checkedColor, footerBackgroundColor: $footerBackgroundColor, gridBackgroundColor: $gridBackgroundColor, gridBorderColor: $gridBorderColor, headerBackgroundColor: $headerBackgroundColor, inactivatedBorderColor: $inactivatedBorderColor, selectedRowColor: $selectedRowColor, tableOuterBackgroundColor: $tableOuterBackgroundColor)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Viewer'))
      ..add(DiagnosticsProperty('activatedBorderColor', activatedBorderColor))
      ..add(DiagnosticsProperty('activatedColor', activatedColor))
      ..add(DiagnosticsProperty('borderColor', borderColor))
      ..add(DiagnosticsProperty('cellColorInEditState', cellColorInEditState))
      ..add(DiagnosticsProperty(
          'cellColorInReadOnlyState', cellColorInReadOnlyState))
      ..add(DiagnosticsProperty('cellTextStyle', cellTextStyle))
      ..add(DiagnosticsProperty('checkedColor', checkedColor))
      ..add(DiagnosticsProperty('footerBackgroundColor', footerBackgroundColor))
      ..add(DiagnosticsProperty('gridBackgroundColor', gridBackgroundColor))
      ..add(DiagnosticsProperty('gridBorderColor', gridBorderColor))
      ..add(DiagnosticsProperty('headerBackgroundColor', headerBackgroundColor))
      ..add(
          DiagnosticsProperty('inactivatedBorderColor', inactivatedBorderColor))
      ..add(DiagnosticsProperty('selectedRowColor', selectedRowColor))
      ..add(DiagnosticsProperty(
          'tableOuterBackgroundColor', tableOuterBackgroundColor));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Viewer &&
            const DeepCollectionEquality()
                .equals(other.activatedBorderColor, activatedBorderColor) &&
            const DeepCollectionEquality()
                .equals(other.activatedColor, activatedColor) &&
            const DeepCollectionEquality()
                .equals(other.borderColor, borderColor) &&
            const DeepCollectionEquality()
                .equals(other.cellColorInEditState, cellColorInEditState) &&
            const DeepCollectionEquality().equals(
                other.cellColorInReadOnlyState, cellColorInReadOnlyState) &&
            const DeepCollectionEquality()
                .equals(other.cellTextStyle, cellTextStyle) &&
            const DeepCollectionEquality()
                .equals(other.checkedColor, checkedColor) &&
            const DeepCollectionEquality()
                .equals(other.footerBackgroundColor, footerBackgroundColor) &&
            const DeepCollectionEquality()
                .equals(other.gridBackgroundColor, gridBackgroundColor) &&
            const DeepCollectionEquality()
                .equals(other.gridBorderColor, gridBorderColor) &&
            const DeepCollectionEquality()
                .equals(other.headerBackgroundColor, headerBackgroundColor) &&
            const DeepCollectionEquality()
                .equals(other.inactivatedBorderColor, inactivatedBorderColor) &&
            const DeepCollectionEquality()
                .equals(other.selectedRowColor, selectedRowColor) &&
            const DeepCollectionEquality().equals(
                other.tableOuterBackgroundColor, tableOuterBackgroundColor));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(activatedBorderColor),
      const DeepCollectionEquality().hash(activatedColor),
      const DeepCollectionEquality().hash(borderColor),
      const DeepCollectionEquality().hash(cellColorInEditState),
      const DeepCollectionEquality().hash(cellColorInReadOnlyState),
      const DeepCollectionEquality().hash(cellTextStyle),
      const DeepCollectionEquality().hash(checkedColor),
      const DeepCollectionEquality().hash(footerBackgroundColor),
      const DeepCollectionEquality().hash(gridBackgroundColor),
      const DeepCollectionEquality().hash(gridBorderColor),
      const DeepCollectionEquality().hash(headerBackgroundColor),
      const DeepCollectionEquality().hash(inactivatedBorderColor),
      const DeepCollectionEquality().hash(selectedRowColor),
      const DeepCollectionEquality().hash(tableOuterBackgroundColor));

  @JsonKey(ignore: true)
  @override
  _$ViewerCopyWith<_Viewer> get copyWith =>
      __$ViewerCopyWithImpl<_Viewer>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ViewerToJson(this);
  }
}

abstract class _Viewer implements Viewer {
  const factory _Viewer(
      {String? activatedBorderColor,
      String? activatedColor,
      String? borderColor,
      String? cellColorInEditState,
      String? cellColorInReadOnlyState,
      String? cellTextStyle,
      String? checkedColor,
      String? footerBackgroundColor,
      String? gridBackgroundColor,
      String? gridBorderColor,
      String? headerBackgroundColor,
      String? inactivatedBorderColor,
      String? selectedRowColor,
      String? tableOuterBackgroundColor}) = _$_Viewer;

  factory _Viewer.fromJson(Map<String, dynamic> json) = _$_Viewer.fromJson;

  @override
  String? get activatedBorderColor;
  @override
  String? get activatedColor;
  @override
  String? get borderColor;
  @override
  String? get cellColorInEditState;
  @override
  String? get cellColorInReadOnlyState;
  @override
  String? get cellTextStyle;
  @override
  String? get checkedColor;
  @override
  String? get footerBackgroundColor;
  @override
  String? get gridBackgroundColor;
  @override
  String? get gridBorderColor;
  @override
  String? get headerBackgroundColor;
  @override
  String? get inactivatedBorderColor;
  @override
  String? get selectedRowColor;
  @override
  String? get tableOuterBackgroundColor;
  @override
  @JsonKey(ignore: true)
  _$ViewerCopyWith<_Viewer> get copyWith => throw _privateConstructorUsedError;
}

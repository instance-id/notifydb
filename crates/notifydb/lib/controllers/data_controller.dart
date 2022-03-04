import 'dart:async';
import 'dart:convert' as convert;
import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:notifydb/controllers/table_controller.dart';

import '../model/app_settings.dart';
import '../model/settings_data.dart';
import '../models/notification_model.dart' as n;
import '../utils/logger.dart';
import '../utils/bool_parsing.dart';
import '../widgets/adw_custom_combo_row.dart';

class DataController extends GetxController {
  final _dataChannel = MethodChannel('database_channel');
  final _settingChannel = MethodChannel('settings_channel');

  var comboKey = GlobalKey<AdwComboButtonState>();

  final _isReady = false.obs;
  late SettingsData _settings_data;
  late AppSettings _app_settings;
  late LocalWindow localWindow;

  final _logLevel = 'error'.obs;
  final _logLevelIndex = 0.obs;
  final _logLevelPopup = false.obs;
  List<n.Notification> _notification_list = <n.Notification>[].obs;
  var logLevelList = ['debug', 'info', 'warning', 'error'];
  late Timer timer;

  late VoidCallback? logLevelDropdown;

  // --| App Settings --------------------
  // --|----------------------------------
  final _settingsIndex = (1 - 2).obs;

  int get settingsIndex => _settingsIndex.value;

  void setSettingsIndex(int s) {
    _settingsIndex.value = s;
  }

  // --| Auto Refresh --------------------------------
  final _isRefreshing = false.obs;
  final _autoRefresh = false.obs;

  bool get autoRefresh => _autoRefresh.value;

  bool get isRefreshing => _isRefreshing.value;

  void setIsRefreshing(bool b) {
    _isRefreshing.value = b;
  }

  void setAutoRefresh(bool r, {updateSettings = true}) {
    _autoRefresh.value = r;

    if (autoRefresh) {
      Future.delayed(Duration(milliseconds: 500), () {
        timer = runPeriodically(checkForNewNotifications);
      });

      setIsRefreshing(true);
    } else {
      if (isRefreshing) {
        timer.cancel();
        setIsRefreshing(false);
      }
    }

    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        autoRefresh: r.toString(),
      ));
      updateAppSettings();
    }
  }

  // --| Auto Refresh Interval -----------------------
  final _autoRefreshInterval = '5'.obs;

  String get autoRefreshInterval => _autoRefreshInterval.value;

  void setAutoRefreshInterval(String r, {updateSettings = true}) {
    _autoRefreshInterval.value = r;
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        autoRefreshInterval: int.parse(r),
      ));
      updateAppSettings();
    }
  }

  // --| Auto Mark Read ------------------------------
  final _autoMarkUnread = false.obs;

  bool get autoMarkUnread => _autoMarkUnread.value;

  void setAutoMarkUnread(bool r, {updateSettings = true}) {
    _autoMarkUnread.value = r;
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        refreshOnMarkAsRead: r.toString(),
      ));
      updateAppSettings();
    }
  }

  // --| Enable Animation ----------------------------
  final _enableAnimation = false.obs;

  bool get enableAnimation => _enableAnimation.value;

  void setEnableAnimation(bool r, {updateSettings = true}) {
    _enableAnimation.value = r;
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        animations: r.toString(),
      ));
      updateAppSettings();
    }
  }

  // --| Max Loaded Messages -------------------------
  final _maxLoaded = 1000.obs;

  int get maxLoaded => _maxLoaded.value;

  void setMaxLoadedMessages(int max, {updateSettings = true}) {
    _maxLoaded.value = max;
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        maxLoadedMessages: max,
      ));
      updateAppSettings();
    }
  }

  // --| Max Per Page --------------------------------
  final _maxPerPage = 50.obs;

  int get maxPerPage => _maxPerPage.value;

  void setMaxPerPage(int max, {updateSettings = true}) {
    _maxPerPage.value = max;
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        maxPerPage: max,
      ));
      updateAppSettings();
    }
  }

  // --| Enable Animation ----------------------------
  final _deleteReadMessages = true.obs;

  bool get deleteReadMessages => _deleteReadMessages.value;

  void setDeleteReadMessages(bool r, {updateSettings = true}) {
    _deleteReadMessages.value = r;
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        deleteReadMessages: r.toString(),
      ));
      updateAppSettings();
    }
  }

  // --| Set Log Level -------------------------------
  void setLogLevel(String level, {updateSettings = true, updateLevelIndex = false}) {
    _logLevel.value = level;
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        logLevel: level.toString(),
      ));
      updateAppSettings();
    }

    if (updateLevelIndex) {
      _logLevelIndex.value = logLevelList.indexOf(level);
    }
  }

  void setLogLevelIndex(int level) {
    Logger.debug('Setting log level to $level ${logLevelList[level]}');
    setLogLevel(logLevelList[level]);
    _logLevelIndex.value = level;
    Logger.debug('log level $logLevel');
  }

  void setLogLevelPopup(bool value) {
    _logLevelPopup.value = value;
  }

  // --| Window Position -----------------------------
  var windowDefault = '''{"width":1000,"height":550,"is_minimized":false,"is_maximized":false,"is_full_screen":false,"is_active":false}''';

  final _windowSize = ''.obs;

  String get windowSize => _windowSize.value;

  void setWindowSize(String size) => _windowSize.value = size;

  void saveWindowSize(String windowStr, {updateSettings = true}) {
    setWindowSize(windowStr);
    if (updateSettings) {
      _app_settings = _app_settings.copyWith(
          settings: _app_settings.settings.copyWith(
        windowSize: windowStr.toString(),
      ));
      updateAppSettings();
    }
  }

  // --| Initialization ------------------------------
  // --|----------------------------------------------
  //@formatter:off
  void Initialization() {
    Future.microtask(() => applySettings(getAppSettings('notifydb')));
    Future.microtask(() => GetSettings());
  }

  void InitData() { Future.microtask(() => GetData()); }
  //@formatter:on

  void applySettings(Future<AppSettings> appSettings) {
    Settings s;

    appSettings.then((value) => {
          s = _app_settings.settings,
          setMaxLoadedMessages(s.maxLoadedMessages!, updateSettings: false),
          setMaxPerPage(s.maxPerPage!, updateSettings: false),
          setAutoRefresh(s.autoRefresh!.parseBool(), updateSettings: false),
          setAutoRefreshInterval(s.autoRefreshInterval.toString(), updateSettings: false),
          setAutoMarkUnread(s.refreshOnMarkAsRead!.parseBool(), updateSettings: false),
          setEnableAnimation(s.animations!.parseBool(), updateSettings: false),
          setDeleteReadMessages(s.deleteReadMessages!.parseBool(), updateSettings: false),
          setWindowSize(s.windowSize!.toString())
        });
  }

  Future<void> GetAppSettings() async {
    try { //@formatter:off
      var settings = getSettings('viewer');
      await settings.then((value) {
        _settings_data = value;
        setLogLevel(_settings_data.database.logLevel ?? 'error');
        Logger.debug('Received settings: $settings');
      });
    }
    catch (e) {Future.microtask(() => print(e.toString())); Logger.error(e.toString()); }
  } //@formatter:on

  Future<void> GetSettings() async {
    try { //@formatter:off
      var settings = getSettings('viewer');
      await settings.then((value) {
        _settings_data = value;
        setLogLevel(_settings_data.database.logLevel ?? 'error', updateLevelIndex: true, updateSettings: false);
        Logger.debug('Received settings: $settings');
      });
    }
    catch (e) {Future.microtask(() => print(e.toString())); Logger.error(e.toString()); }
  } //@formatter:on

  Future<void> GetData() async {
    try { //@formatter:off
      var notifyData = getData('all');
      await notifyData.then((value) { _notification_list = value;});
    }
    catch (e) { Logger.error(e.toString()); }
    finally {
      setIsReady(true);
    }
  } //@formatter:on

  // --| Getters -------------------------------------
  //@formatter:off
  bool get isReady => _isReady.value;
  String get logLevel => _logLevel.value;
  int get logLevelIndex => _logLevelIndex.value;
  bool get logLevelPopup => _logLevelPopup.value;
  SettingsData get settings_data => _settings_data;
  List<n.Notification> get notification_list => _notification_list;
  List<n.Notification> getNotifications() {
    return notification_list;
  }

  void setIsReady(bool value) { _isReady.value = value; }
  //@formatter:on

  // --| Functions ------------------------------
  Timer runPeriodically(void Function() callback) => Timer.periodic(Duration(seconds: int.parse(autoRefreshInterval)), (timer) => callback());

  void queryDatabase(String query_string) async {
    final result = await _dataChannel.invokeMethod('query', query_string);
    Logger.debug(result);
  }

  Future<String> markSelected(List<int> selected) async {
    final result = await _dataChannel.invokeMethod('markSelected', {'selected': selected, 'delete': deleteReadMessages});
    Logger.debug(result);
    return result;
  }

  void checkForNewNotifications() async {
    final result = await _dataChannel.invokeMethod('get_notification_count');

    if ((result as int) > notification_list.length || Get.find<TableController>().markRefresh) {
      refreshNotifications('all', Get.find<TableController>().setNeedsRefresh);
      Get.find<TableController>().setMarkRefresh(false);
    }
    Logger.debug('Current notification count:  ${result.toString()}');
  }

  void refreshNotifications(String query_string, void Function(bool value) setNeedsRefresh) {
    var notifyData = getData('all');
    notifyData.then((value) {
      Logger.debug('Refresh count: ${(value as List<n.Notification>).length}');
      _notification_list = value;
      setNeedsRefresh(true);
    });
  }

  // --| Get Toml Settings -------------------------------------
  // --|--------------------------------------------------------
  Future<SettingsData> getSettings(String arguments) async {
    final settings;
    try {
      settings = await _settingChannel.invokeMethod('get_app_settings', arguments);
      return settingsDataFromJson(settings);
    } catch (e) {
      Future.microtask(() => print(e.toString()));
      rethrow;
    }
    return settingsDataFromJson('');
  }

  // --| Get DB Settings ---------------------------------------
  // --|--------------------------------------------------------
  Future<AppSettings> getAppSettings(String arguments) async {
    try {
      final settings = await _dataChannel.invokeMethod('get_settings', arguments);

      if ((settings as String).contains('Not_found')) {
        _app_settings = await updateAppSettings(useDefaults: true);
      } else {
        _app_settings = appSettingsFromJson(convert.jsonDecode(settings.substring(1, settings.length - 1))['settings_json']);
        return _app_settings;
      }
    } catch (e) {
      Future.microtask(() => print(e.toString()));
      rethrow;
    }

    return _app_settings;
  }

  // --| Update DB Settings ------------------------------------
  // --|--------------------------------------------------------
  Future updateAppSettings({useDefaults = false}) async {
    if (useDefaults || _app_settings.toJson().toString().isEmpty) {
      Logger.info('Applying default settings');
      return appSettingsFromJson(defaultSettings);
    }

    var settings_json = appSettingsToJson(_app_settings);
    var package = {'app_name': _app_settings.appName, 'settings': settings_json};
    final result = await _dataChannel.invokeMethod('update_settings', package);
    Logger.debug('Update app settings: ${(result as String)}');

    return result;
  }

  // --| Get Notification Data ---------------------------------
  // --|--------------------------------------------------------
  Future getData(String query) async {
    switch (query) {
      case 'one':
        final value = await _dataChannel.invokeMethod('query_database', query);
        var unwrapJson = (value as String).substring(1, value.length - 1);
        var jsonObject = convert.jsonDecode(unwrapJson);

        var result = n.Notification.fromJson(jsonObject);
        return result;

      case 'all':
        final value = await _dataChannel.invokeMethod('query_database', [query, maxLoaded.toString()]);
        var jsonObject = convert.jsonDecode(value) as List;
        var result = jsonObject.map((notification) => n.Notification.fromJson(notification)).toList();
        return result;

      default:
    }
  }

  void dispatchIntent(Intent intent) {
    final primaryContext = primaryFocus?.context;
    if (primaryContext != null) {
      final action = Actions.maybeFind<Intent>(primaryContext, intent: intent);
      if (action != null && action.isEnabled(intent)) {
        Actions.of(primaryContext).invokeAction(action, intent, primaryContext);
      }
    }
  }

  var defaultSettings = '''{
  "appName": "notifydb",
  "settings": {
    "animations": "true",
    "autoRefresh": "true",
    "autoRefreshInterval": 3,
    "refreshOnMarkAsRead": "true",
    "logLevel": "error"
  }
}''';
}

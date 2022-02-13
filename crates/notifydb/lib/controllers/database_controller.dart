import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/logger.dart';

class DatabaseController extends GetxController {
  final _channel = MethodChannel('database_channel');

  void queryDatabase(String query_string) async {
    final result = await _channel.invokeMethod('query', query_string);
    Logger.write(result);
  }

  void dispatchIntent(Intent intent) {
    final primaryContext = primaryFocus?.context;
    if (primaryContext != null) {
      final action = Actions.maybeFind<Intent>(
        primaryContext,
        intent: intent,
      );
      if (action != null && action.isEnabled(intent)) {
        Actions.of(primaryContext).invokeAction(action, intent, primaryContext);
      }
    }
  }
}

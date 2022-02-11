import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class PlatformController extends GetxController{
  final _channel = MethodChannel('window_channel');

  void WindowAction(String action) async {
    final _ = await _channel.invokeMethod('window', action);
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

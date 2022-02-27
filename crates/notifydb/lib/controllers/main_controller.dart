// ignore_for_file: always_declare_return_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:nativeshell/nativeshell.dart';

class MainController extends GetxController {
  late WindowState windowState;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var appInitialSize = Size(1000, 550);
  var debug = true.obs;
  var menuIndex = 0.obs;

  get mainIndex => menuIndex.toInt();

  bool isDebug() {
    return debug.value;
  }

  void setDebug(bool value) {
    debug.value = value;
  }

  // --| Settings Flap ---------------------
  final flapController = FlapController();
  final _showRefreshButton = false.obs;

  get showRefreshButton => _showRefreshButton.value;

  void setShowRefresh(bool r) {
    _showRefreshButton.update((value) {
      value = r;
    });
  }
  // --|------------------------------------

  bool _toggle = false;

  void toggleDrawer() {
    _toggle = !_toggle;
    if (_toggle) {
      scaffoldKey.currentState?.openDrawer();
    } else {
      scaffoldKey.currentState?.openEndDrawer();
    }
  }

  // --| Initialization --------------------
  // --|------------------------------------
  @override
  void onInit() {
    super.onInit();
  }

  void initialize(BuildContext context) async {
    try {
      flapController.close(context: context);
    } catch (e) {
      return;
    }
  }
}

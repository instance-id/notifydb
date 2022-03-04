// ignore_for_file: always_declare_return_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:nativeshell/nativeshell.dart';

import '../widgets/custom_flap_controller.dart';
import 'table_controller.dart';

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
  late AnimationController animationController;
  final flapController = CustomFlapController();
  final Duration duration = Duration(milliseconds: 500);
  var animatingForward = true;
  var calledOnce = false;

  final _showRefreshButton = false.obs;

  get showRefreshButton => _showRefreshButton.value;

  void setShowRefresh(bool r) {
    _showRefreshButton.update((value) {
      value = r;
    });
  }

  // --|------------------------------------

  final _settingsMenu = false.obs;

  bool get settingsMenu => _settingsMenu.value;

  void toggleSettings() {
    _settingsMenu.value = !_settingsMenu.value;
    if (settingsMenu) {
      flapController.open();
    } else {
      flapController.close();
    }
  }

  // --| Initialization --------------------
  // --|------------------------------------
  @override
  void onInit() {
    super.onInit();
    // flapController.addListener(() {
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     Get.find<TableController>().stateManager.notifyListeners();
    //   });
    // });
  }

  @override
  onClose() {
    super.onClose();
    // flapController.removeListener(() {
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     Get.find<TableController>().stateManager.notifyListeners();
    //   });
    // });
  }

  void initialize(BuildContext context) async {
    try {
      flapController.close(context: context);
    } catch (e) {
      return;
    }
  }
}

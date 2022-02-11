import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nativeshell/nativeshell.dart';

import '../controllers/controller.dart';

class Home extends WindowState {
  @override
  Widget build(context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final c = Get.put(Controller());

    return IntrinsicWidth(
        child: Scaffold(
      // Use Obx(()=> to update Text() whenever count is changed.
      appBar: AppBar(title: Obx(() => Text('Clicks: ${c.count}'))),

      body: Center(
          child: ElevatedButton(
              child: const Text('Go to Other'), onPressed: () => null)),
      // Get.to(Other())

      floatingActionButton: FloatingActionButton(
          onPressed: c.increment, child: const Icon(Icons.add)),
    ));
  }

  @override
  WindowSizingMode get windowSizingMode =>
      WindowSizingMode.atLeastIntrinsicSize;

  @override
  Future<void> initializeWindow(Size intrinsicContentSize) async {
    if (Platform.isMacOS) {
      await Menu(_buildMenu).setAsAppMenu();
    }
    await window.setTitle('NativeShell Examples');
    return super.initializeWindow(intrinsicContentSize);
  }

  // -- Build Menu -----------------------------------a
  List<MenuItem> _buildMenu() => [
        MenuItem.children(title: 'App', children: [
          MenuItem.withRole(role: MenuItemRole.hide),
          MenuItem.withRole(role: MenuItemRole.hideOtherApplications),
          MenuItem.withRole(role: MenuItemRole.showAll),
          MenuItem.separator(),
          MenuItem.withRole(role: MenuItemRole.quitApplication),
        ]),
        MenuItem.children(title: 'Window', role: MenuRole.window, children: [
          MenuItem.withRole(role: MenuItemRole.minimizeWindow),
          MenuItem.withRole(role: MenuItemRole.zoomWindow),
        ]),
      ];
}

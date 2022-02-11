import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:adwaita/adwaita.dart';
import 'package:notifydb/controllers/platform.dart';
import 'package:notifydb/utils/logger.dart';
import 'package:window_decorations/window_decorations.dart';
import 'package:get/get.dart';

void main() async {
  disableShaderWarmUp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      logWriterCallback: Logger.write,
      theme: AdwaitaThemeData.dark(),
      home: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        child: Container(
          color: Colors.black,
          child: WindowWidget(
            onCreateState: (initData) {
              WindowState? state;
              state ??= MainWindowState();
              return state;
            },
          ),
        ),
      ),
    );
  }
}

class MainWindowState extends WindowState {
  final pc = Get.put(PlatformController());

  @override
  Future<void> initializeWindow(Size intrinsicContentSize) async {
    await window
        .setStyle(WindowStyle(canResize: true, frame: WindowFrame.noTitle));
    await window.show();
  }

  Future<void> windowAction(String action) async {
    switch (action) {
      case 'hide':
        await window.hide();
        break;
      case 'restore':
        await window.activate();
        break;
      case 'quit':
        await window.close();
        break;
      default:
    }
  }

  @override
  WindowSizingMode get windowSizingMode =>
      WindowSizingMode.atLeastIntrinsicSize;

  final ThemeType _currentThemeType = ThemeType.auto;
  int? _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WindowLayoutProbe(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
      AdwHeaderBar.minimalNativeshell(height: 30, window: window, start: [
        Builder(builder: (context) {
          return AdwHeaderButton(
              icon: const Icon(Icons.view_sidebar, size: 15),
              // isActive: _flapController.isOpen,
              onPressed: () {
                // _flapController.toggle();
              });
        })
      ], end: [
        DecoratedMinimizeButton(
          width: 25,
          type: _currentThemeType,
          onPressed: () => windowAction('hide'),
        ),
        DecoratedMaximizeButton(
          width: 25,
          type: _currentThemeType,
          onPressed: () => windowAction('restore'),
        ),
        DecoratedCloseButton(
          width: 25,
          type: _currentThemeType,
          onPressed: () => windowAction('quit'),
        )
      ]),
      Container(
        height: 450,
        width: 800,
        // padding: EdgeInsets.all(20),a
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // --| Left Side Column ---------------------------------------
            // --|---------------------------------------------------------
            Expanded(
                child: Column(children: [
              AdwPreferencesGroup(
                  children: List.generate(
                      3,
                      (index) => ListTile(
                        dense: true,
                            title: Text('Index $index'),
                          )))
            ])),
            // --| Right Side Column ---------------------------------------
            // --|---------------------------------------------------------
            Expanded(
                child: Column(
              children: [
                AdwPreferencesGroup(
                  children: [
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: const Text('Expander row'),
                        children: [
                          const ListTile(
                            title: Text('A nested row'),
                          ),
                          Divider(
                            color: context.borderColor,
                            height: 10,
                          ),
                          const ListTile(
                            title: Text('Another nested row'),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            )),
          ],
        ),
      )
    ]));
  }
}

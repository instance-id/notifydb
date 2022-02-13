import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:notifydb/utils/logger.dart';
import 'package:window_decorations/window_decorations.dart';

import '../controllers/main_controller.dart';
import '../services/app_services.dart';
import '../main.dart';
import '../view/home_view.dart';
import '../widgets/side_menu.dart';

class MainView extends StatefulWidget {
  MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final ThemeType _currentThemeType = ThemeType.auto;

  @override
  void initState() {
    getIt.isReady<AppServices>().then((_) =>  getIt<AppServices>().addListener(update));

    super.initState();
  }

  @override
  void dispose() {
    getIt<AppServices>().removeListener(update);
    super.dispose();
  }

  void update() => setState(() => {});

  Future<void> windowAction(String action) async {
    switch (action) {
      case 'hide':
        Logger.write('Minimizing');
        await Window.of(context).setMinimized(true);
        break;
      case 'restore':
        Logger.write('Restore');
        await Window.of(context).activate();
        break;
      case 'quit':
        Logger.write('Quit');
        await Window.of(context).close();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainApp = Get.put(MainController());

    return Expanded(
        child: Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // --| Header Bar ----------------------------------------
      // --|----------------------------------------------------
      AdwHeaderBar.minimalNativeshell(height: 35, padding: EdgeInsets.only(left: 0, right: 0), titlebarSpace: 10, window: Window.of(context), start: [
        Builder(builder: (context) {
          return AdwHeaderButton(
              icon: const Icon(Icons.view_sidebar, size: 15),
              // isActive: _flapController.isOpen,
              onPressed: () {
                // _flapController.toggle();
              });
        })
      ],

          // --| Window Controls ---------------------
          // --|--------------------------------------
          end: [
            DecoratedMinimizeButton(
              width: 25,
              height: 25,
              type: _currentThemeType,
              onPressed: () => windowAction('hide'),
            ),
            DecoratedMaximizeButton(
              width: 25,
              height: 25,
              type: _currentThemeType,
              onPressed: () => windowAction('restore'),
            ),
            DecoratedCloseButton(
              width: 25,
              height: 25,
              type: _currentThemeType,
              onPressed: () => windowAction('quit'),
            )
          ]),

      // --| Main Application View -----------------------------
      // --|----------------------------------------------------
      FutureBuilder(
          future: getIt.allReady(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                flex: 1,
                child: Container(
                    child: Row(mainAxisSize: MainAxisSize.max, children: [
                  // --| Left Side Column ----------
                  // --|----------------------------
                  Container(
                    child: Obx(
                      () => NavigationSideBar(selectedIndex: mainApp.menuIndex.toInt(), onIndexSelect: mainApp.menuIndex),
                    ),
                  ),
                  // Expanded(flex: 15, child: CategoryView()),

                  // --| Right Side Column ---------
                  // --|----------------------------
                  Expanded(flex: 80, child: Home()),
                ])),
              );
            } else {
              // --| Loading View --------------------
              // --|----------------------------------
              return Container(
                height: 450,
                width: 900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('Waiting for initialisation'),
                    SizedBox(
                      height: 15,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }
          })
    ]));
  }
}

// Expanded(child: NotificationData()),
//     Column(children: [
//   Text(
//     getIt<AppModel>().counter.toString(),
//     style: Theme.of(context).textTheme.headline4,
//   ),
//   AdwButton(
//     onPressed: getIt<AppModel>().incrementCounter,
//     child: Icon(Icons.add),
//   ),
//   AdwPreferencesGroup(
//       children: List.generate(
//           3,
//           (index) => ListTile(
//                 dense: true,
//                 title: Text('Index $index'),
//               )))
// ])

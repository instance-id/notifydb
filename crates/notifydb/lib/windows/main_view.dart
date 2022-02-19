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
    getIt.isReady<AppServices>().then((_) => getIt<AppServices>().addListener(update));

    super.initState();
  }

  @override
  void dispose() {
    getIt<AppServices>().removeListener(update);
    super.dispose();
  }

  void update() => setState(() => {});

  Future<void> windowAction(String action, LocalWindow window) async {
    switch (action) {
      case 'hide':
        await window.setMinimized(true);
        Logger.debug('Minimizing');
        break;
      case 'restore':
        await window.setMinimized(false);
        Logger.debug('Restoring');
        break;
      case 'quit':
        await window.close();
        Logger.debug('Quit');
        break;
      default:
    }
  }

  DecoratedCloseButton closeHandler({void Function()? onTap}) {
    return DecoratedCloseButton(
      width: 25,
      height: 25,
      type: _currentThemeType,
      onPressed: () => onTap?.call(),
    );
  }

  DecoratedMinimizeButton minimizeHandler({void Function()? onTap}) {
    return DecoratedMinimizeButton(
      width: 25,
      height: 25,
      type: _currentThemeType,
      onPressed: () => onTap?.call(),
    );
  }

  DecoratedMaximizeButton maximizeHandler({void Function()? onTap}) {
    return DecoratedMaximizeButton(
      width: 25,
      height: 25,
      type: _currentThemeType,
      onPressed: () => onTap?.call(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainApp = Get.put(MainController());
    var window = Window.of(context);

    return Expanded(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --| Header Bar ----------------------------------------
        // --|----------------------------------------------------
        AdwHeaderBar.customNativeshell(
          height: 35,
          padding: EdgeInsets.only(left: 0, right: 0),
          titlebarSpace: 10,
          window: window,
          closeBtn: (void Function()? onTap) => closeHandler(onTap: onTap),
          minimizeBtn: (void Function()? onTap) => minimizeHandler(onTap: onTap),
          maximizeBtn: (void Function()? onTap) => maximizeHandler(onTap: onTap),
          start: [
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
          //   DecoratedMinimizeButton(
          //     width: 25,
          //     height: 25,
          //     type: _currentThemeType,
          //     onPressed: () => Future.microtask(() => window.setMinimized(true)),
          //   ),
          //   DecoratedMaximizeButton(
          //     width: 25,
          //     height: 25,
          //     type: _currentThemeType,
          //     onPressed: () => window.setMinimized(true),
          //         // Future.microtask(() => window.setMinimized(false)),
          //   ),
          //   DecoratedCloseButton(
          //     width: 25,
          //     height: 25,
          //     type: _currentThemeType,
          //     onPressed: () => windowAction('quit', window),
          //   )
          ]
        ),

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
                        () => NavigationSideBar(
                            selectedIndex: mainApp.menuIndex.toInt(), onIndexSelect: mainApp.menuIndex),
                      ),
                    ),

                    // --| Right Side Column ---------
                    // --|----------------------------
                    Expanded(flex: 80, child: Home()),
                  ])),
                );
              } else {
                // --| Loading View --------------------
                // --|----------------------------------
                return Container(
                  height: mainApp.appInitialSize.height,
                  width: mainApp.appInitialSize.width,
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
      ],
    ));
  }
}

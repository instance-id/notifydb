import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:window_decorations/window_decorations.dart';

import '../controllers/data_controller.dart';
import '../controllers/main_controller.dart';
import '../view/home_view.dart';
import '../widgets/side_menu.dart';

class MainView extends StatefulWidget {
  MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final ThemeType _currentThemeType = ThemeType.auto;
  MainController mainController = Get.find<MainController>();

  @override
  void initState() {
    Get.find<DataController>().InitData();
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //@formatter:off
  DecoratedCloseButton closeHandler({void Function()? onTap}) {
    return DecoratedCloseButton(width: 25, height: 25,
      type: _currentThemeType,
      onPressed: () => onTap?.call());
  }

  DecoratedMinimizeButton minimizeHandler({void Function()? onTap}) {
    return DecoratedMinimizeButton(width: 25, height: 25,
      type: _currentThemeType,
      onPressed: () => onTap?.call());
  }

  DecoratedMaximizeButton maximizeHandler({void Function()? onTap}) {
    return DecoratedMaximizeButton(width: 25, height: 25,
      type: _currentThemeType,
      onPressed: () => onTap?.call());
  } //@formatter:on

  Widget MainView() {
    var dataController = Get.find<DataController>();
    return Expanded(
      flex: 1,
      child: Container(
          child: Row(
        children: [
          Container(
            child: Obx(
              // --| Navigation ------------
              () => NavigationSideBar(
                selectedIndex: mainController.menuIndex.toInt(),
                onIndexSelect: mainController.menuIndex,
              ),
            ),
          ),
          // --| Right Side Column ---------
          // --|----------------------------
          //@formatter:off
          Expanded(flex: 80,
              child: Obx(() =>
              dataController.isReady
                  ? Home()
                  : LoadingView()
              )),
          //@formatter:on
        ],
      )),
    );
  }

  Widget LoadingView() {
    // --| Loading View --------------------
    // --|----------------------------------
    return IntrinsicSizedBox(
      // intrinsicHeight: mainController.appInitialSize.height,
      // intrinsicWidth: mainController.appInitialSize.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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

  @override
  Widget build(BuildContext context) {
    var window = Window.of(context);
    var dataController = Get.find<DataController>();

    return IntrinsicSizedBox(
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --| Header Bar --------------
            // --|--------------------------
            AdwHeaderBar.customNativeshell(
                height: 35,
                padding: EdgeInsets.only(left: 0, right: 0),
                titlebarSpace: 5,
                window: window,
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
                // --| Window Controls -----
                // --|----------------------
                end: [
                  Builder(builder: (context) {
                    return AdwHeaderButton(
                        icon: const Icon(Icons.minimize, size: 15),
                        onPressed: () {
                          window.setMinimized(true);
                        });
                  }),
                  Builder(builder: (context) {
                    return AdwHeaderButton(
                        icon: const Icon(Icons.close, size: 15),
                        // isActive: _flapController.isOpen,
                        onPressed: () {
                          window.onCloseRequested();
                        });
                  })
                ]),
            // --| Main Application View ---
            // --|--------------------------
            MainView()
          ],
        ),
      ),
    );
  }
}

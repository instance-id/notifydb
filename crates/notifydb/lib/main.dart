import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:adwaita/adwaita.dart';
import 'package:notifydb/utils/logger.dart';
import 'package:notifydb/windows/main_view.dart';
import 'package:get/get.dart';

import 'controllers/database_controller.dart';
import 'controllers/table_controller.dart';
import 'controllers/main_controller.dart';
import 'services/app_services.dart';

GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  disableShaderWarmUp();
  getIt.registerSingleton<AppServices>(AppServicesImpl(), signalsReady: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(MainController());
    Get.put(TableController());
    Get.put(DatabaseController());

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
              state.window.getGeometry();
              return state;
            },
          ),
        ),
      ),
    );
  }
}

class MainWindowState extends WindowState {

  @override
  Future<void> initializeWindow(Size intrinsicContentSize) async {
    var geometry = Geometry(frameSize: Size(800, 450), contentSize: intrinsicContentSize);
    await window.setGeometry(geometry);
    await window.setStyle(WindowStyle(canResize: true, frame: WindowFrame.noTitle));
    return super.initializeWindow(intrinsicContentSize);
  }

  @override
  WindowSizingMode get windowSizingMode => WindowSizingMode.atLeastIntrinsicSize;

  @override
  Widget build(BuildContext context) {
    return WindowLayoutProbe(child: MainView());
  }
}

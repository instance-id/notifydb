import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:nativeshell/nativeshell.dart';

import '../controllers/data_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/table_controller.dart';
import '../utils/ColorUtil.dart';
import '../utils/logger.dart';
import '../widgets/table/table_view.dart';
import 'settings_flap.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  late final MainController mainController = Get.find<MainController>();
  late final TableController tableController = Get.find<TableController>();
  late final DataController dataController = Get.find<DataController>();

  Future<void> markSelected() async {
    var selectedIds = tableController.selectedIds();
    if (selectedIds.isEmpty) {
      Logger.debug('No rows selected');
      return;
    }

    Logger.debug('selectedIds: $selectedIds');
    var result = await dataController.markSelected(selectedIds);
    tableController.updateSelectedRows(result);
  }

  // --| Theme Related ---------------------
  final ttTheme = BoxDecoration(
    color: GetColor.parse('#282828'),
    border: Border.all(
      color: GetColor.parse('#161616FF'),
      width: 1,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(4)),
  );
  final ttText = TextStyle(fontSize: 12, color: Colors.white);

  Widget enabledRefresh() {
    return Tooltip(
      message: 'Click to refresh notifications',
      decoration: ttTheme,
      textStyle: ttText,
      waitDuration: Duration(milliseconds: 900),
      child: IconButton(
        padding: EdgeInsets.fromLTRB(8, 8, 14, 8),
        icon: Icon(Icons.update),
        onPressed: () => dataController.refreshNotifications('all', tableController.setNeedsRefresh),
      ),
    );
  }

  Widget disabledRefresh() {
    return Tooltip(
      message: 'Auto Refresh Enabled',
      decoration: ttTheme,
      textStyle: ttText,
      waitDuration: Duration(milliseconds: 900),
      child: IconButton(
        color: Colors.black38,
        padding: EdgeInsets.fromLTRB(8, 8, 14, 8),
        icon: Icon(Icons.update),
        onPressed: () => {},
      ),
    );
  }

  @override
  Widget build(context) {
    return IntrinsicSizedBox(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          // --| Notification number -----------------
          title: Obx(
            () => Text('Notifications: ${tableController.itemsShown}'),
          ),
          actions: [
            // --| TEST BUTTONS ---------------------v
            Obx(() {
              if (dataController.logLevelIndex == 0) {
                return Row(
                  children: [
                    Tooltip(
                      message: 'Force update of application settings to/from database',
                      decoration: ttTheme,
                      textStyle: ttText,
                      waitDuration: Duration(milliseconds: 900),
                      child: IconButton(
                        padding: EdgeInsets.fromLTRB(8, 8, 14, 8),
                        icon: Icon(Icons.system_update_alt_rounded),
                        onPressed: () => Future.microtask(() => dataController.updateAppSettings()),
                      ),
                    ),
                    Tooltip(
                      message:
                          'Manually get and log current notification count. If new notifications are found, pull and rebuild table.',
                      decoration: ttTheme,
                      textStyle: ttText,
                      waitDuration: Duration(milliseconds: 900),
                      child: IconButton(
                        padding: EdgeInsets.fromLTRB(8, 8, 14, 8),
                        icon: Icon(Icons.arrow_circle_down_sharp),
                        onPressed: () => Future.microtask(() => dataController.checkForNewNotifications()),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
            // --| TEST BUTTONS ---------------------^

            // --| Refresh ---------------------------
            Obx(() => dataController.isRefreshing ? disabledRefresh() : enabledRefresh()),
          ],
        ),

        // --| Body ----------------------------------
        body: Stack(children: <Widget>[
          AdwFlap(
            style: FlapStyle(
              locked: false,
              flapWidth: 245,
              foldPolicy: FoldPolicy.never,
            ),
            controller: mainController.flapController,
            // --| Settings --------------------------
            flap: SettingsFlap(),
            // --| Table View ------------------------
            child: Center(child: TableView()),
          )
        ]),

        // --| Mark Selected -------------------------
        floatingActionButton: Obx(() => tableController.isSelected
            ? FloatingActionButton(
                onPressed: () => markSelected(),
                backgroundColor: Colors.orange.withOpacity(0.6),
                child: Icon(
                  Icons.check,
                  color: Colors.black54,
                  size: 24,
                ),
              )
            : Container()),
      ),
    );
  }
}

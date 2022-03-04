import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:nativeshell/nativeshell.dart';

import '../controllers/data_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/table_controller.dart';
import '../utils/ColorUtil.dart';
import '../utils/logger.dart';
import '../widgets/adw_custom_flap.dart';
import '../widgets/table/table_view.dart';
import 'settings_flap.dart';

class Home extends HookWidget {
  Home({Key? key}) : super(key: key);

  final MainController mainController = Get.find<MainController>();
  final TableController tableController = Get.find<TableController>();
  final DataController dataController = Get.find<DataController>();

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
      message: 'Click to refresh notifications. Long press to switch to automatic refresh.',
      decoration: ttTheme,
      textStyle: ttText,
      waitDuration: Duration(milliseconds: 900),
      child: GestureDetector(
        onLongPress: () => dataController.setAutoRefresh(!dataController.autoRefresh),
        child: IconButton(
          color: Colors.white60,
          padding: EdgeInsets.fromLTRB(8, 8, 14, 8),
          icon: Icon(Icons.update),
          onPressed: () => dataController.refreshNotifications('all', tableController.setNeedsRefresh),
        ),
      ),
    );
  }

  Widget disabledRefresh() {
    return Tooltip(
        message: 'Auto Refresh Enabled. Long press to switch to manual refresh.',
        decoration: ttTheme,
        textStyle: ttText,
        waitDuration: Duration(milliseconds: 900),
        child: GestureDetector(
          onLongPress: () => dataController.setAutoRefresh(!dataController.autoRefresh),
          child: Stack(
            children: [
              IconButton(
                color: Colors.black38,
                padding: EdgeInsets.fromLTRB(8, 8, 14, 8),
                icon: Icon(Icons.update),
                onPressed: () => {},
              ),
              Positioned(
                right: 15,
                top: 18,
                child: Text(
                  'Auto',
                  style: TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ),
            ],
          ),
        ));
  }

  void initializeListener(AnimationController controller) {
    controller.addListener(() {
      controller.status == AnimationStatus.forward
          ? mainController.animatingForward = true
          : mainController.animatingForward = false;

      if (mainController.animatingForward && controller.value > 0.1) {
        tableController.rebuildCallback.call();
      }

      if (!mainController.animatingForward && controller.value < 0.9) {
        tableController.rebuildCallback.call();
      }

      if (controller.isCompleted) {
        Future.delayed(Duration(milliseconds: 100), () {
          mainController.animatingForward = false;
          tableController.rebuildCallback.call();
        });
      }
    });
  }

  @override
  Widget build(context) {
    final controller = useAnimationController(duration: mainController.duration);

    if (!mainController.calledOnce) {
      mainController.calledOnce = true;
      initializeListener(controller);
    }

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
          AdwCustomFlap(
            animationController: controller,
            style: FlapCustomStyle(
              locked: false,
              flapWidth: 245,
              foldPolicy: CustomFoldPolicy.never,
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
                  size: 20,
                ),
              )
            : Container()),
      ),
    );
  }
}

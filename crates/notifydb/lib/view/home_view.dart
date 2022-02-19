import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notifydb/main.dart';

import '../controllers/database_controller.dart';
import '../controllers/table_controller.dart';
import '../services/app_services.dart';
import '../utils/logger.dart';
import '../widgets/table/table_view.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  late final TableController tableController;
  late final DatabaseController databaseController;

  Future<void> markSelected() async {
    var selectedIds = tableController.selectedIds();
    if (selectedIds.isEmpty) {
      Logger.debug('No rows selected');
      return;
    }

    Logger.debug('selectedIds: $selectedIds');
    var result = await databaseController.markSelected(selectedIds);
    tableController.updateSelectedRows(result);
  }

  @override
  Widget build(context) {
    tableController = Get.find<TableController>();
    databaseController = Get.find<DatabaseController>();

    return IntrinsicWidth(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          // --| Notification number -------
          title: Obx(
            () => Text('Notifications: ${tableController.itemsShown}'),
          ),
          actions: [
            // --| Refresh -----------------
            Obx(() => tableController.getShowRefresh
                ? IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => {},
                  )
                : Container()),
          ],
        ),
        // --| Body ------------------------
        body: Center(
          // --| Table View ----------------
          // --|----------------------------
          child: TableView(),
        ), // Get.to(Other())
        floatingActionButton: Obx(() => tableController.isSelected
            ? FloatingActionButton(
                onPressed: () => markSelected(),
                child: Icon(Icons.check, color: Colors.orange),
              )
            : Container()),
      ),
    );
  }
}

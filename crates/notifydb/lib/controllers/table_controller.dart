import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notifydb/utils/logger.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TableController extends GetxController {
  late final PlutoGridStateManager stateManager;
  var rightOffset = 0.0.obs;
  var columnWidth = 0.0.obs;
  var itemsSelected = false.obs;
  var selectedCount = 0.obs;
  var itemsShown = 0.obs;

  var showRefresh = false.obs;
  var selectedRows = <PlutoRow>[];

  bool get getShowRefresh => showRefresh.value;
  bool get isSelected => selectedCount.value > 0;

  int getShownCount(){ return itemsShown.value; }
  void setShownCount(int count){ itemsShown.value = count; }
  void setSelected(selectedCount) { this.selectedCount.value = selectedCount; }

  List<int> selectedIds() {
    var idList = <int>[];
    selectedRows.forEach((row) { idList.add(int.parse(row.cells['id']?.value)); });

    return idList;
  }

  void updateSelectedRows(String result) {
    if (result == 'Success'){
      selectedRows.forEach((row) {
        row.cells['status']?.value = 'read';
        stateManager.setRowChecked(row, false);
      });
      selectedCount.value = stateManager.checkedRows.length;
    } else {
      Logger.error('Could not update notification status: $result');
    }
  }
}

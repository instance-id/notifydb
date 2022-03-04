import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notifydb/utils/logger.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TableController extends GetxController {
  late final PlutoGridStateManager stateManager;
  late VoidCallback rebuildCallback;
  var selectedRows = <PlutoRow>[];

  var rightOffset = 0.0.obs;
  var columnWidth = 0.0.obs;
  var itemsSelected = false.obs;
  var selectedCount = 0.obs;
  var itemsShown = 0.obs;
  final _rebuildTable = false.obs;
  final _markRefresh = false.obs;


  // --| Getters and Setters -------------------
  bool get rebuildTable => _rebuildTable.value;
  bool get markRefresh => _markRefresh.value;
  bool get isSelected => selectedCount.value > 0;

  void setNeedsRefresh(bool value) {
    _rebuildTable.value = value;
  }

  void setMarkRefresh(bool value) {
    _markRefresh.value = value;
  }

  int getShownCount() {
    return itemsShown.value;
  }

  void setShownCount(int count) {
    itemsShown.value = count;
  }

  void setSelected(selectedCount) {
    this.selectedCount.value = selectedCount;
  }

  // --| Public methods -----------------------
  List<int> selectedIds() {
    var idList = <int>[];
    Logger.debug('selectedRows: ${selectedRows.length}');
    selectedRows.forEach((row) {
      Logger.debug('type: ${row.cells['id']?.value.runtimeType}');
      Logger.debug('rowid: ${row.cells['id']?.value}');
    });

    selectedRows.forEach((row) {
      idList.add(row.cells['id']?.value);
    });

    return idList;
  }

  void updateSelectedRows(String result) {
    if (result == 'Success') {
      selectedRows.forEach((row) {
        row.cells['status']?.value = 'read';
        stateManager.setRowChecked(row, false);
      });

      selectedCount.value = stateManager.checkedRows.length;
      setMarkRefresh(true);
    } else {
      Logger.error('Could not update notification status: $result');
    }
  }
}

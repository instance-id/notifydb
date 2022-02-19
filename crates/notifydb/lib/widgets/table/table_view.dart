import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notifydb/widgets/table/custom_filter.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sized_context/sized_context.dart';

import '../../controllers/table_controller.dart';
import '../../main.dart';
import '../../model/settings_data.dart';
import '../../services/app_services.dart';
import '../../utils/ColorUtil.dart';
import '../../utils/logger.dart';
import 'custom_column_menu.dart';
import 'custom_footer.dart';
import 'message_details.dart';

class TableView extends StatefulWidget {
  const TableView({Key? key}) : super(key: key);

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  // --| Service Locators ----------------------------
  // --|----------------------------------------------
  var notifications = getIt.get<AppServices>().notification_list;
  final Viewer settings = getIt.get<AppServices>().settings_data.viewer;
  final tableController = Get.find<TableController>();

  // --| Variables -----------------------------------
  // --|----------------------------------------------
  late final PlutoGridStateManager stateManager;
  late PlutoGrid grid;
  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];
  final List<String> uniqueSenders = [];
  final Map<String, int> senderCount = {};
  final Map<String, String> displayMap = {};

  // late TapGestureRecognizer tap = TapGestureRecognizer();
  // late final GestureTapCallback? onTap;

  late Color headerBackgroundColor;
  late Color gridBackgroundColor;
  late Color gridBorderColor;
  late Color cellTextStyle;
  late Color footerBackgroundColor;
  late Color tableOuterBackgroundColor;
  late Color selectedRowColor;
  late double frozenWidth;

  double lastWidth = 0;
  double colHeight = 0;
  RxDouble colWidth = 0.0.obs;
  bool hasChanged = false;
  double priorOffset = 0;
  bool needsUpdate = false;
  late RxDouble offset;

  // --| Column Definition --------------------------------
  // --|---------------------------------------------------
  List<PlutoColumn> buildColumns() {
    return <PlutoColumn>[
      PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.number(),
        hide: true,
      ),
      PlutoColumn(
        title: 'Application',
        field: 'application',
        type: PlutoColumnType.text(),
        readOnly: true,
        enableDropToResize: true,
        width: 100,
        titleSpan: TextSpan(
          text: 'Sender',
          recognizer: TapGestureRecognizer()
            ..onTapUp = (event) {
              _showContextMenu(context, event.globalPosition);
            },
        ),
        enableContextMenu: false,
        enableSorting: false,
        enableColumnDrag: false,
      ),
      PlutoColumn(
        title: 'Title',
        field: 'title',
        type: PlutoColumnType.text(),
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
      ),
      PlutoColumn(
        title: 'Message',
        field: 'message',
        type: PlutoColumnType.text(),
        readOnly: true,
        enableColumnDrag: false,
      ),
      PlutoColumn(
        title: 'Sent Date',
        field: 'sent_date',
        width: 135,
        type: PlutoColumnType.date(format: 'MM-dd-yyyy HH:mm:ss', applyFormatOnInit: false),
        // sort: PlutoColumnSort.descending,
        readOnly: true,
        enableDropToResize: false,
        enableContextMenu: false,
        enableSorting: false,
        enableColumnDrag: false,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        width: 95,
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.left,
        enableRowChecked: true,
        readOnly: true,
        enableDropToResize: false,
        enableContextMenu: false,
        enableSorting: false,
        enableColumnDrag: false,
      ),
    ];
  }

  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: false),
    PlutoColumnGroup(title: 'Application information', fields: ['application', 'title']),
    PlutoColumnGroup(title: 'Etc.', fields: ['sent_date']),
  ];

  // --| Initialization ------------------------------
  // --|----------------------------------------------
  @override
  void initState() {
    Logger.debug('TableView.initState');
    headerBackgroundColor = GetColor.parse(settings.headerBackgroundColor!);
    gridBackgroundColor = GetColor.parse(settings.gridBackgroundColor!);
    gridBorderColor = GetColor.parse(settings.gridBorderColor!);
    cellTextStyle = GetColor.parse(settings.cellTextStyle!);
    footerBackgroundColor = GetColor.parse(settings.footerBackgroundColor!);
    tableOuterBackgroundColor = GetColor.parse(settings.tableOuterBackgroundColor!);
    selectedRowColor = GetColor.parse(settings.selectedRowColor!);

    Logger.debug('BuildGrid');
    grid = BuildGrid();
    setState(() {});

    super.initState();
    Logger.debug('Init Complete');
  }

  @override
  void dispose() {
    stateManager.removeListener(() => columnSizer());
    super.dispose();
  }

  // --| Utility Functions ---------------------------------
  // --|----------------------------------------------------
  void columnSizer() {
    needsUpdate = false;
    if (priorOffset != stateManager.rightBlankOffset) {
      needsUpdate = true;
      priorOffset = stateManager.rightBlankOffset;
    }

    if ((stateManager.rightBlankOffset > 0.2 || stateManager.rightBlankOffset < -0.2) && needsUpdate) {
      stateManager.resizeColumn(columns[3], stateManager.rightBlankOffset);
      needsUpdate = false;
    }
  }

  bool checkFiltered() {
    return stateManager.filterRows.isEmpty;
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final selectedMenu = await showFilterColumnMenu(
      context: context,
      position: position,
      stateManager: stateManager,
      column: columns[1],
      filterItems: uniqueSenders,
      displayMap: displayMap,
    );

    Logger.debug('selectedMenu: $selectedMenu');
    Logger.debug('checkFiltered: $checkFiltered()');

    switch (selectedMenu) {
      case 'clear':
        stateManager.setFilter(null, notify: false);
        stateManager.resetPage(notify: true);
        stateManager.setPage(1, notify: false);
        break;
      default:
        if (!checkFiltered()) {
          stateManager.setFilter(null, notify: false);
          stateManager.resetPage(notify: true);
          stateManager.setPage(1, notify: false);
        }

        var filteredRows = checkFiltered()
            ? [
                FilterHelper.createFilterRow(
                  columnField: columns[1].field,
                  filterType: SenderNameFilter(),
                  filterValue: selectedMenu,
                ),
              ]
            : stateManager.filterRows;

        Logger.debug('filter rows: ${filteredRows.length}');
        if (selectedMenu != null) {
          stateManager.setFilterWithFilterRows(filteredRows, notify: true);
        }
        break;
    }

    checkFiltered()
        ? tableController.setShownCount(stateManager.refRows.originalLength)
        : tableController.setShownCount(stateManager.refRows.filteredList.length);
  }

  // --| Populate rows -------------------------------------
  // --|----------------------------------------------------
  List<PlutoRow> buildNotificationList() {
    rows.clear();
    uniqueSenders.clear();
    senderCount.clear();
    displayMap.clear();

    notifications.reversed.forEach((element) {
      var appName = element.appname!;
      if (appName.isEmpty) {
        Logger.error('appname is empty: id: ${element.id} message: ${element.summary}');
      }

      senderCount.update('$appName', (value) => value + 1, ifAbsent: () => 1);

      if (!uniqueSenders.contains('$appName')) {
        uniqueSenders.add('$appName');
      }

      rows.add(PlutoRow(
        sortIdx: int.tryParse(element.id),
        cells: {
          'id': PlutoCell(value: element.id),
          'application': PlutoCell(value: element.appname),
          'title': PlutoCell(value: element.summary),
          'message': PlutoCell(value: element.body),
          'sent_date': PlutoCell(value: element.Created_at),
          'status': PlutoCell(value: 'unread'),
        },
      ));
    });

    senderCount.forEach((key, value) {
      Logger.debug('$key: $value');
      displayMap[key] = '$key: ${value.toString()}';
    });

    uniqueSenders.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    tableController.setShownCount(rows.length);
    return rows;
  }

  // --| Build Table Grid ---------------------------------
  // --|---------------------------------------------------
  PlutoGrid BuildGrid() {
    var settings = getIt.get<AppServices>().settings_data.viewer;

    columns.addAll(buildColumns());

    columns.forEach((column) {
      column.backgroundColor = headerBackgroundColor;
    });

    grid = PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        stateManager = event.stateManager;
        tableController.stateManager = stateManager;

        // --| Build Notification List --------------------
        buildNotificationList();

        setState(() {});

        stateManager.setPage(2, notify: false);
        hasChanged = true;
        stateManager.setPage(1, notify: false);
        stateManager.notifyListenersOnPostFrame();
        stateManager.addListener(() => columnSizer());
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        hasChanged = true;
      },
      configuration: PlutoGridConfiguration.dark(
          enableColumnFlex: true,
          gridBackgroundColor: gridBackgroundColor,
          gridBorderColor: gridBorderColor,
          enableColumnBorder: true,
          cellTextStyle: TextStyle(color: cellTextStyle, fontSize: 12),
          rowHeight: 25,
          columnHeight: 30,
          footerCustomHeight: 35,
          scrollbarConfig: PlutoGridScrollbarConfig(
            scrollbarThickness: 10.0,
            scrollbarThicknessWhileDragging: 10.0,
            isAlwaysShown: false,
          ),
          columnFilterConfig: PlutoGridColumnFilterConfig(filters: [
            SenderNameFilter(),
          ])),
      mode: PlutoGridMode.selectWithOneTap,
      onSelected: (PlutoGridOnSelectedEvent event) {
        if (event.row != null) {
          // --| Open message details view -----------------
          openDetail(event.row, context, stateManager);
          hasChanged = true;
        }
      },
      onRowChecked: (PlutoGridOnRowCheckedEvent event) {
        hasChanged = true;

        Logger.debug('${event.row?.cells['status']?.value} Checked: ${event.isChecked}');

        if (stateManager.checkedRows.isNotEmpty) {
          tableController.setSelected(stateManager.checkedRows.length);
        }

        tableController.selectedRows = stateManager.checkedRows;

        if (event.isChecked!) {
          stateManager.toggleSelectingRow(rows.indexOf(event.row!));
          Logger.debug('Selected: ${stateManager.currentSelectingRows.length}');
        }

        if (stateManager.checkedRows.isEmpty) {
          tableController.setSelected(0);
          stateManager.setSelecting(false);
        }
      },
      onRowsMoved: (PlutoGridOnRowsMovedEvent event) => {hasChanged = true},
      rowColorCallback: (c) {
        return c.row.checked == true ? selectedRowColor : Colors.transparent;
      },
      createFooter: (stateManager) {
        stateManager.setPageSize(100, notify: false);
        return Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          color: footerBackgroundColor,
          child: Expanded(
            child: CustomPagination(stateManager),
          )
        );
      },
    );

    hasChanged = true;
    return grid;
  }

  void resizeColumn() {
    if (colWidth.toDouble() != lastWidth || hasChanged) {
      if (lastWidth != 0) {
        columns[3].width = stateManager.rightFrozenLeftOffset - stateManager.bodyColumnsWidthAtColumnIdx(2);
        stateManager.notifyListeners();
      }

      lastWidth = colWidth.toDouble();
      hasChanged = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    colWidth.value = context.widthPx;
    colHeight = context.heightPx;

    if (colWidth.toDouble() != lastWidth) {
      lastWidth = colWidth.toDouble();
      stateManager.notifyListenersOnPostFrame();
    }

    return Scaffold(
      backgroundColor: tableOuterBackgroundColor,
      body: Container(
        color: tableOuterBackgroundColor,
        padding: const EdgeInsets.all(15),
        child: grid,
      ),
    );
  }
}

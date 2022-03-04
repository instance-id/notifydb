import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sized_context/sized_context.dart';

import '../../controllers/data_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/table_controller.dart';
import '../../model/settings_data.dart';
import '../../utils/ColorUtil.dart';
import '../../utils/logger.dart';

import 'message_details.dart';
import 'custom_column_menu.dart';
import 'message_text_filter.dart';
import 'sender_name_filter.dart';
import 'custom_footer.dart';
import 'title_text_filter.dart';

class TableView extends StatefulWidget {
  const TableView({Key? key}) : super(key: key);

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  // --| Service Locators ----------------------------
  // --|----------------------------------------------

  var notifications = Get.find<DataController>().notification_list;
  final Viewer settings = Get.find<DataController>().settings_data.viewer;
  final tableController = Get.find<TableController>();

  // --| Variables -----------------------------------
  // --|----------------------------------------------
  late final PlutoGridStateManager stateManager;
  late final MainController mainController;
  late PlutoGrid grid;
  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];
  final List<String> uniqueSenders = [];
  final Map<String, int> senderCount = {};
  final Map<String, String> displayMap = {};

  late Color headerBackgroundColor;
  late Color gridBackgroundColor;
  late Color gridBorderColor;
  late Color filterBorderColor;
  late Color cellColorInEditState;
  late Color activatedBorderColor;
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
  bool initialized = false;
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
        // enableFilterMenuItem: false,
      ),
      PlutoColumn(
        title: 'Title',
        field: 'title',
        type: PlutoColumnType.text(),
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        enableDropToResize: true,
        enableFilterMenuItem: true,
        titleSpan: TextSpan(
          text: 'Title',
          recognizer: TapGestureRecognizer()
            ..onTapUp = (event) {
              setShowFilterInput();
            },
        ),
      ),
      PlutoColumn(
        title: 'Message',
        field: 'message',
        type: PlutoColumnType.text(),
        readOnly: true,
        enableColumnDrag: false,
        enableSorting: false,
        enableAutoEditing: false,
        enableHideColumnMenuItem: false,
        enableDropToResize: false,
        enableSetColumnsMenuItem: false,
        enableContextMenu: false,
        enableFilterMenuItem: true,
        titleSpan: TextSpan(
          text: 'Message',
          recognizer: TapGestureRecognizer()
            ..onTapUp = (event) {
              setShowFilterInput();
            },
        ),
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
        enableFilterMenuItem: false,
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
        enableFilterMenuItem: false,
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
    tableController.rebuildCallback = () => columnSizer();

    headerBackgroundColor = GetColor.parse(settings.headerBackgroundColor!);
    gridBackgroundColor = GetColor.parse(settings.gridBackgroundColor!);
    gridBorderColor = GetColor.parse(settings.gridBorderColor!);
    filterBorderColor = GetColor.parse(settings.filterBorderColor!);
    cellColorInEditState = GetColor.parse(settings.cellColorInEditState!);
    activatedBorderColor = GetColor.parse(settings.activatedBorderColor!);
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

  // --| Utility Functions --------------------------------
  // --|---------------------------------------------------
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

  // --| Column Filters -----------------------------------
  // --|---------------------------------------------------

  var filterShown = false;

  void setShowFilterInput() {
    filterShown = !filterShown;
    stateManager.setShowColumnFilter(filterShown);
  }

  bool checkFiltered() {
    return stateManager.filterRows.isEmpty;
  }

  String currentlyFiltered = '';

  void _showContextMenu(BuildContext context, Offset position) async {
    final selectedMenu = await showFilterColumnMenu(
      context: context,
      position: position,
      stateManager: stateManager,
      column: columns[1],
      filterItems: uniqueSenders,
      displayMap: displayMap,
    );

    switch (selectedMenu) {
      case 'clear':
        currentlyFiltered = '';
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

        if (selectedMenu != null) {
          currentlyFiltered = selectedMenu;
          stateManager.setFilterWithFilterRows(filteredRows, notify: true);
        }
        break;
    }

    checkFiltered()
        ? tableController.setShownCount(stateManager.refRows.originalLength)
        : tableController.setShownCount(stateManager.refRows.filteredList.length);
  }

  // --| Populate rows ------------------------------------
  // --|---------------------------------------------------
  void buildNotificationList() {
    Logger.debug('build notification list');

    rows.clear();
    uniqueSenders.clear();
    senderCount.clear();
    displayMap.clear();

    notifications = Get.find<DataController>().notification_list;

    notifications.reversed.forEach((element) {
      var appName = element.appname!;
      if (appName.isEmpty) {
        Logger.error('appname is empty: id: ${element.id} message: ${element.summary}');
      }

      senderCount.update('$appName', (value) => value + 1, ifAbsent: () => 1);

      if (!uniqueSenders.contains('$appName')) {
        uniqueSenders.add('$appName');
      }

      var unescape = HtmlUnescape();

      rows.add(PlutoRow(
        sortIdx: element.id,
        cells: {
          'id': PlutoCell(value: element.id),
          'application': PlutoCell(value: element.appname),
          'title': PlutoCell(value: unescape.convert(element.summary!)),
          'message': PlutoCell(value: unescape.convert(element.body!)),
          'sent_date': PlutoCell(value: element.Created_at),
          'status': PlutoCell(value: 'unread'),
        },
      ));
    });

    senderCount.forEach((key, value) {
      displayMap[key] = '$key: ${value.toString()}';
    });

    uniqueSenders.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    Future.microtask(() {
      tableController.setShownCount(rows.length);
    });
  }

  PlutoGrid RebuildGrid() {
    tableController.setNeedsRefresh(false);
    if (initialized) {
      buildNotificationList();

      if (!uniqueSenders.contains(currentlyFiltered) || stateManager.refRows.filteredList.isEmpty) {
        stateManager.setFilter(null, notify: false);
        stateManager.resetPage(notify: true);
        stateManager.setPage(1, notify: false);
      }

      stateManager.notifyListenersOnPostFrame();
    }
    return grid;
  }

  Color rowColorFunction(PlutoRowColorContext c) {
    return (c.row.checked == true || c.stateManager.isSelectedRow(c.row.key) == true)
        ? selectedRowColor
        : Colors.transparent;
  }

  // --| Build Table Grid ---------------------------------
  // --|---------------------------------------------------
  PlutoGrid BuildGrid() {
    Logger.debug('Building Table');

    columns.clear();
    columns.addAll(buildColumns());

    columns.forEach((column) {
      column.columnTitleBackgroundColor = headerBackgroundColor;
    });

    var table = PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        Logger.debug('onLoaded');
        stateManager = event.stateManager;
        tableController.stateManager = stateManager;
        initialized = true;

        // --| Build Notification List --------------------
        buildNotificationList();

        setState(() {});

        stateManager.setSelectingMode(PlutoGridSelectingMode.row);

        // --| Hack to fix the rows not sorting when using pagination
        stateManager.setPage(2, notify: false);
        hasChanged = true;
        stateManager.setPage(1, notify: false);
        // --|-------------------------------------------------------
        stateManager.notifyListenersOnPostFrame();
        stateManager.addListener(() => columnSizer());
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        Logger.debug('onChanged');
        hasChanged = true;
      },
      configuration: PlutoGridConfiguration.dark(
        gridBackgroundColor: gridBackgroundColor,
        gridBorderColor: gridBorderColor,
        filterBorderColor: filterBorderColor,
        cellColorInEditState: cellColorInEditState,
        activatedBorderColor: activatedBorderColor,
        enableColumnBorder: true,
        cellTextStyle: TextStyle(color: cellTextStyle, fontSize: 12),
        rowHeight: 30,
        columnHeight: 30,
        columnFilterHeight: 30,
        footerCustomHeight: 35,
        scrollbarConfig: PlutoGridScrollbarConfig(
          scrollbarThickness: 10.0,
          scrollbarThicknessWhileDragging: 10.0,
          isAlwaysShown: false,
        ),
        columnFilterConfig: PlutoGridColumnFilterConfig(
          filters: [SenderNameFilter(), TitleTextFilter(), MessageTextFilter(), PlutoFilterTypeContains()],
          resolveDefaultColumnFilter: (column, resolver) {
            if (column.title == 'Title') {
              return resolver<TitleTextFilter>() as PlutoFilterType;
            } else if (column.title == 'Message') {
              return resolver<MessageTextFilter>() as PlutoFilterType;
            } else { return resolver<PlutoFilterTypeContains>() as PlutoFilterType; }
          },
        ),
      ),
      mode: PlutoGridMode.selectWithOneTap,
      onSelected: (PlutoGridOnSelectedEvent event) {
        Logger.debug('onSelected');
        if (event.row != null) {
          // --| Open message details view -----------------
          openDetail(event.row, context, stateManager);
          stateManager.clearCurrentCell();
          hasChanged = true;
        }
      },
      onRowChecked: (PlutoGridOnRowCheckedEvent event) {
        hasChanged = true;

        Logger.debug('${event.row?.cells['status']?.value} Checked: ${event.isChecked}');

        if (stateManager.checkedRows.isNotEmpty) {
          stateManager.setSelecting(true);
          tableController.setSelected(stateManager.checkedRows.length);
        }

        tableController.selectedRows = stateManager.checkedRows;

        if (stateManager.checkedRows.isEmpty) {
          tableController.setSelected(0);
          stateManager.setSelecting(false);
        }
        stateManager.notifyListeners();
      },
      onRowsMoved: (PlutoGridOnRowsMovedEvent event) => {hasChanged = true},
      rowColorCallback: (c) {
        return rowColorFunction(c);
      },
      createFooter: (stateManager) {
        Logger.debug('createFooter');
        var data = Get.find<DataController>();
        stateManager.setPageSize(data.maxPerPage, notify: false);
        return Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            color: footerBackgroundColor,
            child: Expanded(
              child: CustomPagination(stateManager),
            ));
      },
    );

    hasChanged = true;
    return table;
  }

  @override
  Widget build(BuildContext context) {
    colWidth.value = context.widthPx;
    colHeight = context.heightPx;

    if (colWidth.toDouble() != lastWidth) {
      lastWidth = colWidth.toDouble();
      if (hasChanged) {
        stateManager.notifyListenersOnPostFrame();
      }
    }

    return Scaffold(
      backgroundColor: tableOuterBackgroundColor,
      body: Container(
        color: tableOuterBackgroundColor,
        padding: const EdgeInsets.all(15),
        //@formatter:off
        child: Obx(() => grid = tableController.rebuildTable
            ? RebuildGrid()
            : grid
        ),
        //@formatter:on
      ),
    );
  }
}

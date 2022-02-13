import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifydb/home/notification_model.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../home/notification_model.dart' as notifi;
import '../main.dart';
import '../services/app_services.dart';
import 'message_details.dart';

/// PlutoGrid Example
//
/// For more examples, go to the demo web link on the github below.
class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({Key? key}) : super(key: key);

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  var notifications = getIt.get<AppServices>().notification_list;

  final List<PlutoColumn> columns = <PlutoColumn>[
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
    ),
    PlutoColumn(
      title: 'Title',
      field: 'title',
      type: PlutoColumnType.text(),
      readOnly: true,
    ),
    PlutoColumn(
      title: 'Message',
      field: 'message',
      type: PlutoColumnType.text(),
      readOnly: true,
    ),
    PlutoColumn(
      title: 'Sent Date',
      field: 'sent_date',
      type: PlutoColumnType.date(format: 'yyyy-MM-dd HH:mm:ss'),
      sort: PlutoColumnSort.descending,
      readOnly: true,
    ),
    PlutoColumn(
      title: 'Status',
      field: 'status',
      type: PlutoColumnType.text(),
      textAlign: PlutoColumnTextAlign.left,
      enableRowChecked: true,
      readOnly: true,
      minWidth: 100,
    ),
  ];

  final List<PlutoRow> rows = [];

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: false),
    PlutoColumnGroup(title: 'Application information', fields: ['application', 'title']),
    PlutoColumnGroup(title: 'Etc.', fields: ['sent_date']),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  List<PlutoRow> buildNotificationList() {
    notifications.forEach((element) {
      rows.add(PlutoRow(
        sortIdx: int.tryParse(element.id),
        cells: {
          'id': PlutoCell(value: element.id),
          'application': PlutoCell(value: element.appname),
          'title': PlutoCell(value: element.summary),
          'message': PlutoCell(value: element.body),
          'sent_date': PlutoCell(value: element.Created_at),
          'status': PlutoCell(value: 'unread'),
          // 'select': PlutoCell(value: '')
        },
      ));
    });
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    // --| Build Notification List -------------------
    // --|--------------------------------------------

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: buildNotificationList(),
          // columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.autoFitColumn(context, columns[1]);
            stateManager.autoFitColumn(context, columns[4]);
            stateManager.autoFitColumn(context, columns[5]);
            stateManager.sortDescending(columns[4]);
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          configuration: const PlutoGridConfiguration.dark(
            gridBackgroundColor: Colors.white10,
            gridBorderColor: Colors.black12,
            enableColumnBorder: true,
          ),
          onSelected: (PlutoGridOnSelectedEvent event) {
            if (event.row != null) {
              // --| Open message details view -----------------
              openDetail(event.row, context, stateManager);
            }
          },
          mode: PlutoGridMode.select,
        ),
      ),
    );
  }
}

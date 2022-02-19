import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:pluto_grid/pluto_grid.dart';

Widget buildEntries(PlutoRow? row, BuildContext context) {
  var entries = <Widget>[];

  row!.cells.forEach((key, value) {
    if (key.toString() != 'id' && key.toString() != 'message') {
      entries.add(AdwActionRow(
        title: value.value.toString(),
        end: Text( key.toString()),
      ));
    } else if (key.toString() == 'message') {
      entries.add(AdwActionRow(
        title: value.value.toString(),
      ));
    }
  });

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        // --| Item Header -------------------
        // --|--------------------------------
        AdwPreferencesGroup(children: [...entries])
      ],
    ),
  );
}

void openDetail(PlutoRow? row, BuildContext context, PlutoGridStateManager stateManager) async {
  var currentWidth = context.size?.width.toDouble();
  var currentheight = context.size?.height.toDouble();

  var value = await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          child: LayoutBuilder(
            builder: (ctx, size) {
              return Container(
                padding: const EdgeInsets.all(15),
                width: (currentWidth! * 0.8),
                height: currentheight! * 0.8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notification Details'),
                      const SizedBox(height: 1),
                      // --| Iterate each cell and add to hierarchy ------
                      // --|----------------------------------------------
                      buildEntries(row, context),
                      const SizedBox(height: 1),
                      Center(
                        child: Wrap(
                          spacing: 10,
                          children: [
                            AdwButton(
                              onPressed: () {
                                Navigator.pop(ctx, null);
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      });

  if (value == null || value.isEmpty) {
    return;
  }

  stateManager.changeCellValue(
    stateManager.currentRow!.cells['column_1']!,
    value,
    force: true,
  );
}

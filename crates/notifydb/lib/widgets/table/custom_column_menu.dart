import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

Text _buildTextItem({
  required String text,
  required Color? textColor,
  bool enabled = true,
}) {
  return Text(
    text,
    style: TextStyle(
      color: enabled ? textColor : textColor!.withOpacity(0.5),
      fontSize: 13,
    ),
  );
}

PopupMenuItem<String> _buildMenuItem<String>({
  Widget? child,
  bool enabled = true,
  String? value,
}) {
  return PopupMenuItem<String>(
    value: value,
    height: 36,
    enabled: enabled,
    child: child,
  );
}

/// Open the context menu on the right side of the column.
Future<String?>? showFilterColumnMenu({
  BuildContext? context,
  Offset? position,
  PlutoGridStateManager? stateManager,
  PlutoColumn? column,
  List<String>? filterItems,
  Map<String, String>? displayMap,
}) {
  if (position == null) {
    return null;
  }

  final overlay = Overlay.of(context!)!.context.findRenderObject() as RenderBox;
  final textColor = stateManager!.configuration!.cellTextStyle.color;
  final backgroundColor = stateManager.configuration!.menuBackgroundColor;

  var menuItems = <PopupMenuItem<String>>[];

  filterItems?.forEach((element) {
    menuItems.add(_buildMenuItem(
      value: element,
      child: Container(
        width: 170,
        child: _buildTextItem(
          text: '${displayMap!['$element']}',
          textColor: textColor,
        ),
      ),
    ));
  });

  return showMenu<String>(
    shape: Border.all(width: 0.5),
    context: context,
    color: backgroundColor,
    elevation: 10,
    position: RelativeRect.fromRect(
      position & const Size(40, 40),
      Offset.zero & overlay.size,
    ),
    items: [
      ...menuItems,
      const PopupMenuDivider(),
      _buildMenuItem(
        value: 'clear',
        child: Container(
          width: 150,
          child: _buildTextItem(
            text: 'Clear Filter',
            textColor: textColor,
          ),
        ),
      ),
    ],
  );
}

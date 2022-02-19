import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TableHeader extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns;

  const TableHeader({
    required this.stateManager,
    required this.columns,
    Key? key,
  }) : super(key: key);

  @override
  _TableHeaderState createState() => _TableHeaderState();
}

class _TableHeaderState extends State<TableHeader> {
  @override
  void initState() {
    super.initState();

    widget.stateManager.setSelectingMode(gridSelectingMode);
  }

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  void handleRemoveCurrentRowButton() {
    widget.stateManager.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    widget.stateManager.removeRows(widget.stateManager.currentSelectingRows);
  }

  void handleToggleColumnFilter() {
    widget.stateManager.setShowColumnFilter(!widget.stateManager.showColumnFilter);
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (gridSelectingMode == mode || mode == null) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      widget.stateManager.setSelectingMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: widget.stateManager.footerHeight,
        child: Wrap(
          spacing: 0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AdwButton(
              onPressed: handleToggleColumnFilter,
              child: const Text('Toggle filter'),
            ),
          ],
        ),
      ),
    );
  }
}

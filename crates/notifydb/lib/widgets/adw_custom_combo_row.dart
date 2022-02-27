import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:libadwaita/src/utils/colors.dart';
import 'package:libadwaita/src/widgets/adw/button.dart';
import 'package:popover_gtk/popover_gtk.dart';

import '../controllers/data_controller.dart';

class AdwCustomComboRow extends StatefulWidget {
  const AdwCustomComboRow({
    Key? key,
    this.choices = const [],
    this.start,
    this.end,
    required this.selectedIndex,
    required this.onSelected,
    this.title,
    this.subtitle,
    this.autofocus = false,
    this.enabled = true,
    this.contentPadding,
    this.onTap,
  }) : super(key: key);

  final GestureTapCallback? onTap;

  /// The choices available for this combo row
  final List<String> choices;

  /// The index of the selected choice
  final int selectedIndex;

  /// Executed when a choice is selected
  final ValueSetter<int> onSelected;

  /// The starting elements of this row
  final Widget? start;

  /// The ending elements of this row
  final Widget? end;

  /// The title of this row
  final String? title;

  /// The subtitle of this row
  final String? subtitle;

  /// Whether to focus automatically when this widget is visible
  /// defaults to false
  final bool autofocus;

  /// Whether this combo row is enabled or not, defaults to true
  final bool enabled;

  /// The padding b/w content of this Combo row
  final EdgeInsets? contentPadding;

  @override
  State<AdwCustomComboRow> createState() => _AdwComboRowState();
}

class _AdwComboRowState extends State<AdwCustomComboRow> {
  _AdwComboRowState();

  final GlobalKey<AdwComboButtonState> comboButtonState = GlobalKey<AdwComboButtonState>();

  late AdwComboButton button;
  final DataController dataController = Get.find<DataController>();

    Null Function() touchFunction(BuildContext context) {
    return () {
      if (comboButtonState.currentState!.active) {
        Navigator.of(context).pop();
        comboButtonState.currentState!.active = false;
      } else {
        comboButtonState.currentState?.show();
      }
    };

  }

  @override
  Widget build(BuildContext context) {

    // dataController.logLevelDropdown = touchFunction as VoidCallback?;

    return InkWell(
      borderRadius: BorderRadius.circular(1),
      hoverColor: context.hoverColor,
      onTap: touchFunction(context),
      child: Row(
        children: [
          if (widget.title != null)
            Expanded(
              child: ListTile(
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                contentPadding: widget.contentPadding,
                leading: widget.start,
                //@formatter:off
              title: widget.title != null && widget.title!.isNotEmpty
                  ? Text(widget.title!)
                  : null,
              subtitle: widget.subtitle != null && widget.subtitle!.isNotEmpty
                  ? Text(widget.subtitle!)
                  : null,
                //@formatter:on
              ),
            ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 1),
                Flexible(
                  child: Text(
                    widget.choices[widget.selectedIndex],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                AdwComboButton(
                  key: comboButtonState,
                  choices: widget.choices,
                  selectedIndex: widget.selectedIndex,
                  onSelected: (val) {
                    widget.onSelected(val);
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdwComboButton extends StatefulWidget {
  const AdwComboButton({
    Key? key,
    this.choices = const [],
    required this.onSelected,
    required this.selectedIndex,
  }) : super(key: key);

  /// The choices available for this combo row
  final List<String> choices;

  /// Executed when a choice is selected
  final ValueSetter<int> onSelected;

  /// The index of the selected choice
  final int selectedIndex;

  @override
  State<AdwComboButton> createState() => AdwComboButtonState();
}

/// This is the private State class that goes with MyStatefulWidget.
class AdwComboButtonState extends State<AdwComboButton> {
  AdwComboButtonState();

  bool active = false;

  @override
  Widget build(BuildContext context) => const Icon(Icons.arrow_drop_down);

  void show() {
    showPopover(
      constraints: const BoxConstraints(
        maxWidth: 125,
        // minWidth: 100,
        // minHeight: 100,
      ),
      context: context,
      arrowHeight: 14,
      barrierColor: Colors.transparent,
      shadow: [
        BoxShadow(
          color: context.borderColor,
          blurRadius: 6,
        ),
      ],
      bodyBuilder: (_) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.choices.length,
            (int index) => AdwButton.flat(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.choices[index],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (index == widget.selectedIndex) const Icon(Icons.check, size: 20),
                ],
              ),
              onPressed: () {
                widget.onSelected(index);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
      width: 200,
      backgroundColor: Theme.of(context).cardColor,
    ).whenComplete(() => setState(() => active = false));
  }
}

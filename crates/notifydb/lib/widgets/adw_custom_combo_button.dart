
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita/src/utils/colors.dart';
import 'package:libadwaita/src/widgets/adw/button.dart';
import 'package:popover_gtk/popover_gtk.dart';

class AdwCustomComboButton extends StatefulWidget {
  const AdwCustomComboButton({
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
  State<AdwCustomComboButton> createState() => _AdwCustomComboButtonState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _AdwCustomComboButtonState extends State<AdwCustomComboButton> {
  _AdwCustomComboButtonState();

  bool active = false;

  @override
  Widget build(BuildContext context) => const Icon(Icons.arrow_drop_down);

  void show() {
    showPopover(
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

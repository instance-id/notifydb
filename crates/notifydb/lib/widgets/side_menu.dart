import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';

class NavigationSideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexSelect;
  final mainController = Get.find<MainController>();

  NavigationSideBar({
    Key? key,
    required this.selectedIndex,
    required this.onIndexSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onIndexSelect,
          labelType: NavigationRailLabelType.selected,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.all_inbox, color: Colors.white.withOpacity(0.8)),
              selectedIcon: Icon(Icons.all_inbox_outlined, color: Colors.blue.withOpacity(0.8)),
              label: Text('View All'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.account_tree, color: Colors.white.withOpacity(0.8)),
              selectedIcon: Icon(Icons.account_tree_outlined, color: Colors.blue.withOpacity(0.8)),
              label: Text('By Source'),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 52,
          child: Material(
              child: Obx(
            () => IconButton(
                color: mainController.settingsMenu ? Colors.blue.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                iconSize: 25,
                icon: Icon(Icons.settings),
                onPressed: () => mainController.toggleSettings()),
          )),
        ),
      ],
    );
  }
}

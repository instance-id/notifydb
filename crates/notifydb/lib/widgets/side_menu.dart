import 'package:flutter/material.dart';

class NavigationSideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexSelect;

  const NavigationSideBar({
    Key? key,
    required this.selectedIndex,
    required this.onIndexSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onIndexSelect,
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.all_inbox),
          selectedIcon: Icon(Icons.all_inbox_outlined),
          label: Text('View All'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_tree),
          selectedIcon: Icon(Icons.account_tree_outlined),
          label: Text('By Source'),
        ),
      ],
    );
  }
}
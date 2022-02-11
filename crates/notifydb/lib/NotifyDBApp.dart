import 'package:flutter/material.dart';
import 'package:adwaita/adwaita.dart';

class NotifyDBApp extends StatelessWidget {
  final Widget child;

  NotifyDBApp({required this.child});

  @override
  Widget build(BuildContext context) {
    var theme = _getTheme();
    return MaterialApp(
      theme: theme,
      title: 'NotifyDB',
      darkTheme: theme,
      home: child,
      themeMode: ThemeMode.dark,
    );
  }

  ThemeData _getTheme() {
    final theme = AdwaitaThemeData.dark();
    return theme
        .copyWith(
        colorScheme: theme.colorScheme.copyWith(
            primary: Colors.deepOrange, secondary: Colors.deepOrangeAccent),
        primaryColor: Colors.lightBlue, accentColor: Colors.deepOrangeAccent
    );
  }
}

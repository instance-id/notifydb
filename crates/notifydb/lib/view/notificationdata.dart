import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';

class NotificationData extends StatefulWidget {
  const NotificationData({Key? key}) : super(key: key);

  @override
  _NotificationDataState createState() => _NotificationDataState();
}

class _NotificationDataState extends State<NotificationData> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: [
        AdwPreferencesGroup(
          children: [
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text('Expander row'),
                children: [
                  const ListTile(
                    title: Text('A nested row'),
                  ),
                  Divider(
                    color: context.borderColor,
                    height: 10,
                  ),
                  const ListTile(
                    title: Text('Another nested row'),
                  )
                ],
              ),
            )
          ],
        )
      ],
    ));
  }
}

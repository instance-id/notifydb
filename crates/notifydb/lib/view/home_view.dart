import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notifydb/main.dart';

import '../controllers/controller.dart';
import '../services/app_services.dart';
import '../widgets/table_view.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final c = Get.put(Controller());
    var notification_count = getIt.get<AppServices>().notification_list.length;

    // Use Obx(()=> to update Text() whenever count is changed.
    return IntrinsicWidth(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          // --| Notification number -------
          title:  Text('Notifications: $notification_count'),
          // title: Obx(() => Text('Notifications: ${c.count}')),
        ),
        body: Center(
          // --| Table View ----------------
          child: PlutoGridExamplePage(),
        ), // Get.to(Other())
        floatingActionButton: FloatingActionButton(onPressed: c.increment, child: const Icon(Icons.add)),
      ),
    );
  }
}

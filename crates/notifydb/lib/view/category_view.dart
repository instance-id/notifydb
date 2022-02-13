import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';

import '../controllers/category_controller.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CategoryController());

    return Column(children: [
      AdwPreferencesGroup(
          children: List.generate(
              3,
              (index) => ListTile(
                    dense: true,
                    title: Text('Index $index'),
                  )))
    ]);
  }
}

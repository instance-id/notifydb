import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';

import '../controllers/data_controller.dart';
import '../controllers/main_controller.dart';
import '../utils/ColorUtil.dart';
import '../utils/logger.dart';
import '../widgets/adw_custom_combo_row.dart';
import '../widgets/adw_custom_combo_button.dart';
import '../widgets/intrinsic_limited_box.dart';

class SettingsFlap extends StatelessWidget {
  SettingsFlap({Key? key}) : super(key: key);

  final MainController mainController = Get.find<MainController>();
  final DataController dataController = Get.find<DataController>();

  // --| Tooltip text ----------------------
  final tooltips = [
    'Automatically poll the database for new messages and then display them',
    'The frequency in which to poll the database for new messages',
    'Automatically mark messages as read when you view their popup dialog',
    'Enable application animations',
    'Set logging level',
  ];

  // --| Theme Related ---------------------
  final ttTheme = BoxDecoration(
    color: GetColor.parse('#282828'),
    border: Border.all(
      color: GetColor.parse('#161616FF'),
      width: 1,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(4)),
  );
  final ttText = TextStyle(fontSize: 12, color: Colors.white);
  final unselectedColor = GetColor.parse('#313131');

  AdwCustomComboRow createComboRow() {
    var comboRow = AdwCustomComboRow(
      contentPadding: EdgeInsets.all(0),
      onSelected: (value) => dataController.setLogLevelIndex(value),
      selectedIndex: dataController.logLevel.indexOf(dataController.logLevel),
      choices: dataController.logLevelList,
    );
    return comboRow;
  }

  // --| Tooltip widget --------------------
  @override
  Widget build(BuildContext context) {
    var actions = [
      (value) => dataController.setAutoRefresh(!dataController.autoRefresh),
      (value) => dataController.setAutoRefreshInterval(value),
      (value) => dataController.setAutoMarkUnread(!dataController.autoMarkUnread),
      (value) => dataController.setEnableAnimation(!dataController.enableAnimation),
      (value) => {},
    ];

    return Obx(() => AdwSidebar(
          width: 245,
          onSelected: (int index) {
            actions[index].call(null);
            dataController.setSettingsIndex(index);
            Future.microtask(() => Future.delayed(Duration(milliseconds: 1200)))
                .then((_) => {Logger.debug('SettingsFlap: onSelected: $index'), dataController.setSettingsIndex(-1)});
            Logger.debug('Sidebar item selected: $index');
          },
          currentIndex: dataController.settingsIndex,
          children: [
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                // flex: 1,
                child: Tooltip(
                  message: tooltips[0],
                  waitDuration: Duration(milliseconds: 900),
                  decoration: ttTheme,
                  textStyle: ttText,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AutoRefresh'),
                      Obx(() {
                        return AdwSwitch(
                          onChanged: (value) => dataController.setAutoRefresh(value),
                          value: dataController.autoRefresh,
                        );
                      })
                    ],
                  ),
                ),
              ),
            ),
            if (dataController.isRefreshing)
              AdwSidebarItem(
                unselectedColor: unselectedColor,
                labelWidget: Expanded(
                  flex: 1,
                  child: Tooltip(
                    message: tooltips[1],
                    decoration: ttTheme,
                    textStyle: ttText,
                    waitDuration: Duration(milliseconds: 900),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Interval (Seconds)'),
                        Obx(
                          () => IntrinsicLimitedBox(
                            maxWidth: 50,
                            maxHeight: 25,
                            child: AdwTextField(
                              initialValue: '${dataController.autoRefreshInterval.toString()}',
                              keyboardType: TextInputType.number,
                              // icon: Icons.insert_photo,
                              onChanged: (String s) => dataController.setAutoRefreshInterval(s),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                flex: 1,
                child: Tooltip(
                  message: tooltips[2],
                  decoration: ttTheme,
                  textStyle: ttText,
                  waitDuration: Duration(milliseconds: 900),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Auto Mark Read'),
                      Obx(() {
                        return AdwSwitch(
                          onChanged: (value) => dataController.setAutoMarkUnread(value),
                          value: dataController.autoMarkUnread,
                        );
                      })
                    ],
                  ),
                ),
              ),
            ),
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                flex: 1,
                child: Tooltip(
                  message: tooltips[3],
                  decoration: ttTheme,
                  textStyle: ttText,
                  waitDuration: Duration(milliseconds: 900),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enable Animation'),
                      Obx(() {
                        return AdwSwitch(
                          onChanged: (value) => dataController.setEnableAnimation(value),
                          value: dataController.enableAnimation,
                        );
                      })
                    ],
                  ),
                ),
              ),
            ),
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                // flex: 1,
                child: Tooltip(
                  message: tooltips[4],
                  decoration: ttTheme,
                  textStyle: ttText,
                  waitDuration: Duration(milliseconds: 900),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Log Level'),
                      IntrinsicLimitedBox(
                        maxWidth: 120,
                        child: Obx(() => AdwCustomComboRow(
                              key: dataController.comboKey,
                              contentPadding: EdgeInsets.all(0),
                              onSelected: (value) => dataController.setLogLevelIndex(value),
                              selectedIndex: dataController.logLevelIndex,
                              choices: dataController.logLevelList,
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';

import '../controllers/data_controller.dart';
import '../controllers/main_controller.dart';
import '../utils/ColorUtil.dart';
import '../utils/logger.dart';
import '../widgets/adw_custom_combo_row.dart';
import '../widgets/adw_custom_text_field.dart';
import '../widgets/intrinsic_limited_box.dart';

class SettingsFlap extends StatelessWidget {
  SettingsFlap({Key? key}) : super(key: key);

  final MainController mainController = Get.find<MainController>();
  final DataController dataController = Get.find<DataController>();

  // --| Tooltip text ----------------------
  final tooltips = [
    /* Max Loaded   */ 'Max number of messages to load at once (0 for unlimited)',
    /* Max Per Page */ 'Max number of messages to load per page',
    /* AutoRefresh  */ 'Automatically poll the database for new messages and then display them',
    /* Interval     */ 'The frequency in which to poll the database for new messages',
    /* Auto Mark    */ 'Automatically mark messages as read when you view their popup dialog',
    /* Animation    */ 'Enable application animations',
    /* Delete Read  */ 'When marking a message as read, delete it from the database',
    /* Log Level    */ 'Set logging level',
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
  final numText = TextStyle(
    color: GetColor.parse('#FFFFFF'),
    fontSize: 14,
    fontWeight: FontWeight.w400,
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
      (value) => dataController.setMaxLoadedMessages(dataController.maxLoaded),
      (value) => dataController.setMaxPerPage(dataController.maxPerPage),
      (value) => dataController.setAutoRefresh(!dataController.autoRefresh),
      (value) => dataController.setAutoRefreshInterval(dataController.autoRefreshInterval),
      (value) => dataController.setAutoMarkUnread(!dataController.autoMarkUnread),
      (value) => dataController.setEnableAnimation(!dataController.enableAnimation),
      (value) => dataController.setDeleteReadMessages(!dataController.deleteReadMessages),
      (value) => {},
    ];
    var index = 0;

    return Obx(() => AdwSidebar(
          width: 245,
          onSelected: (int i) {
            actions[i].call(null);
            dataController.setSettingsIndex(i);
            Future.microtask(() => Future.delayed(Duration(milliseconds: 1200)))
                .then((_) => {Logger.debug('SettingsFlap: onSelected: $i'), dataController.setSettingsIndex(-1)});
            Logger.debug('Sidebar item selected: $i');
          },
          currentIndex: dataController.settingsIndex,
          children: [
            // --| Max Loaded Messages ---------------
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                flex: 1,
                child: Tooltip(
                  message: tooltips[0],
                  decoration: ttTheme,
                  textStyle: ttText,
                  waitDuration: Duration(milliseconds: 900),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Loaded'),
                      Obx(
                        () => IntrinsicLimitedBox(
                          maxWidth: 50,
                          maxHeight: 25,
                          child: AdwCustomTextField(
                            textStyle: numText,
                            initialValue: '${dataController.maxLoaded.toString()}',
                            keyboardType: TextInputType.number,
                            onChanged: (String s) => dataController.setMaxLoadedMessages(int.parse(s)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // --| Max Loaded Messages ---------------
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
                      Text('Max Per Page'),
                      Obx(
                        () => IntrinsicLimitedBox(
                          maxWidth: 50,
                          maxHeight: 25,
                          child: AdwCustomTextField(
                            textStyle: numText,
                            initialValue: '${dataController.maxPerPage.toString()}',
                            keyboardType: TextInputType.number,
                            onChanged: (String s) => dataController.setMaxPerPage(int.parse(s)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // --| Auto Refresh ----------------------
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                // flex: 1,
                child: Tooltip(
                  message: tooltips[2],
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
            // --| Refresh Interval ------------------
            if (dataController.isRefreshing)
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
                        Text('Interval (Seconds)'),
                        Obx(
                          () => IntrinsicLimitedBox(
                            maxWidth: 50,
                            maxHeight: 25,
                            child: AdwCustomTextField(
                              textStyle: numText,
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
            // --| Auto Mark as Read -----------------
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                flex: 1,
                child: Tooltip(
                  message: tooltips[4],
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
            // --| Enable Animation ------------------
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                flex: 1,
                child: Tooltip(
                  message: tooltips[5],
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
            // --| Delete Read Messages --------------
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                flex: 1,
                child: Tooltip(
                  message: tooltips[6],
                  decoration: ttTheme,
                  textStyle: ttText,
                  waitDuration: Duration(milliseconds: 900),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delete Read'),
                      Obx(() {
                        return AdwSwitch(
                          onChanged: (value) => dataController.setDeleteReadMessages(value),
                          value: dataController.deleteReadMessages,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            // --| Log Level -------------------------
            AdwSidebarItem(
              unselectedColor: unselectedColor,
              labelWidget: Expanded(
                // flex: 1,
                child: Tooltip(
                  message: tooltips[7],
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

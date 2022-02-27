import 'dart:ui';

import 'package:any_syntax_highlighter/any_syntax_highlighter.dart';
import 'package:any_syntax_highlighter/themes/any_syntax_highlighter_theme.dart';
import 'package:any_syntax_highlighter/themes/any_syntax_highlighter_theme_collection.dart';
import 'package:any_syntax_highlighter/utils/common_keywords.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/tomorrow-night.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../utils/logger.dart';
import 'custom_code_box.dart';
import 'highlight_theme.dart';

class Props {
  Color color;
  String weight, style;
  static String? fontFamily;
  static double? letterSpacing = 1, wordSpacing, fontSize;
  static bool lineNumbers = false;
  static Set<String> fontFeatures = {};
  static String? useGoogleFont;

  Props(this.color, this.weight, this.style);
}

String generateThemeCode(Map<String, Props> theme, Color bgColor) {
  var s = StringBuffer('const AnySyntaxHighlighterTheme(\n    ');
  theme.forEach((key, value) {
    s.write('''$key : TextStyle(
      color: Color.fromRGBO(${value.color.red}, ${value.color.green}, ${value.color.blue}, ${value.color.opacity}),
      fontWeight: FontWeight.${value.weight},
      fontStyle: FontStyle.${value.style},
    ),
    ''');
  });
  s.write('''boxDecoration: BoxDecoration(
      color: Color.fromRGBO(${bgColor.red}, ${bgColor.green}, ${bgColor.blue}, ${bgColor.opacity})
    ),
    letterSpacing: ${Props.letterSpacing},
    wordSpacing: ${Props.wordSpacing},
    fontFamily: "${Props.fontFamily}",
    fontFeatures: [
      ${Props.fontFeatures.join(',\n      ')}
    ],
)''');
  return s.toString();
}

const fontStyles = <String, FontStyle>{'normal': FontStyle.normal, 'italic': FontStyle.italic};
const fontWeights = <String, FontWeight>{
  'bold': FontWeight.bold,
  'normal': FontWeight.normal,
  'w100': FontWeight.w100,
  'w200': FontWeight.w200,
  'w300': FontWeight.w300,
  'w400': FontWeight.w400,
  'w500': FontWeight.w500,
  'w600': FontWeight.w600,
  'w700': FontWeight.w700,
  'w800': FontWeight.w800,
  'w900': FontWeight.w900
};
final fontFeatures = <String, FontFeature>{
  'FontFeature.stylisticSet(6)': FontFeature.stylisticSet(6),
  'FontFeature.tabularFigures()': const FontFeature.tabularFigures(),
  'FontFeature.proportionalFigures()': const FontFeature.proportionalFigures()
};

Widget buildEntries(PlutoRow? row, BuildContext context, BoxConstraints size) {
  var entries = <Widget>[];
  var _text = '';
  late Map<String, Props> _theme;
  late Color _bgColor;
  final _letterSpacingController = TextEditingController(text: '1');
  final scrollController = ScrollController();

  var reservedWordSets = const {'java', 'python', 'cpp', 'csharp', 'cs', 'dart', 'javascript', 'swift', 'bash', 'ruby'};

  Widget highlighter(String code, String language, double fontSize) {
    return HighlightView(
      code,
      language: language.isEmpty ? 'cs' : language,
      theme: highlight_theme,
      padding: EdgeInsets.all(12),
      textStyle: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: fontSize,
      ),
    );
  }

  const start = '```';
  const end = '```';

  row!.cells.forEach((key, value) {
    if (key.toString() != 'id' && key.toString() != 'message') {
      entries.add(AdwActionRow(
        title: value.value.toString(),
        end: Text(key.toString()),
      ));
    } else if (key.toString() == 'message') {
      var msg = value.value.toString();
      var language = 'markdown';
      var fontSize = 16.0;

      // --| Code parser --------------------
      // --|---------------------------------
      if (msg.contains('```')) {
        language = 'cs';
        fontSize = 12;

        final startIndex = msg.indexOf(start);
        final endIndex = msg.indexOf(end, startIndex + start.length);

        var code = msg.substring(startIndex + start.length, endIndex);
        var lang = reservedWordSets.firstWhere((item) => code.toLowerCase().startsWith(item), orElse: () => '');
        if (lang.isNotEmpty) {
          language = lang;
          code = code.replaceAll('$language', '').trimLeft();
        }

        msg = code.trimRight();
        Logger.debug('msg: $msg');
        Logger.debug('language: $language');
      }

      entries.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.maxWidth,
            maxHeight: size.maxHeight,
          ),
          child: SingleChildScrollView(child: Expanded(child: highlighter(msg, language, fontSize))),
        ),
      );
    }
  });

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        // --| Item Header -------------------
        // --|--------------------------------
        AdwPreferencesGroup(children: [...entries])
      ],
    ),
  );
}

void openDetail(PlutoRow? row, BuildContext context, PlutoGridStateManager stateManager) async {
  var currentWidth = context.size?.width.toDouble();
  var currentHeight = context.size?.height.toDouble();

  var value = await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          child: LayoutBuilder(
            builder: (ctx, size) {
              return Container(
                padding: const EdgeInsets.all(15),
                width: (currentWidth! * 0.8),
                height: currentHeight! * 0.8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notification Details'),
                      const SizedBox(height: 1),
                      // --| Iterate each cell and add to hierarchy ------
                      // --|----------------------------------------------
                      buildEntries(row, context, size),
                      const SizedBox(height: 1),
                      Center(
                        child: Wrap(
                          spacing: 1,
                          children: [
                            Expanded(
                              flex: 2,
                              child: AdwButton(
                                onPressed: () {
                                  Navigator.pop(ctx, null);
                                },
                                child: const Text('       Close       '),

                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      });

  if (value == null || value.isEmpty) {
    return;
  }

  stateManager.changeCellValue(
    stateManager.currentRow!.cells['column_1']!,
    value,
    force: true,
  );
}

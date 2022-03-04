import 'package:pluto_grid/pluto_grid.dart';

class MessageTextFilter implements PlutoFilterType {
  @override
  String get title => ' Message Search';

  @override
  // ignore: always_declare_return_types
  PlutoCompareFunction get compare => FilterHelper.compareContains;

  const MessageTextFilter();
}

import 'package:pluto_grid/pluto_grid.dart';

class TitleTextFilter implements PlutoFilterType {
  @override
  String get title => ' Title Search';

  @override
  // ignore: always_declare_return_types
  PlutoCompareFunction get compare => FilterHelper.compareContains;

  const TitleTextFilter();
}

import 'package:pluto_grid/pluto_grid.dart';

class SenderNameFilter implements PlutoFilterType {
  @override
  String get title => 'Sender Name';

  @override
  // ignore: always_declare_return_types
  get compare => ({
    required String? base,
    required String? search,
    required PlutoColumn? column,
  }) {
    var keys = search!.split(',').map((e) => e.toUpperCase()).toList();

    return keys.contains(base!.toUpperCase());
  };

  const SenderNameFilter();
}

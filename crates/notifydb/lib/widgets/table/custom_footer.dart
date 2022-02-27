import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../controllers/data_controller.dart';
import '../../model/settings_data.dart';
import '../../utils/ColorUtil.dart';

class CustomPagination extends PlutoStatefulWidget {
  const CustomPagination(this.stateManager, {Key? key}) : super(key: key);

  @override
  final PlutoGridStateManager stateManager;

  @override
  _PlutoPaginationState createState() => _PlutoPaginationState();
}

abstract class _CustomPaginationStateWithChange extends PlutoStateWithChange<CustomPagination> {
  int page = 1;
  int totalPage = 1;

  @override
  void initState() {
    super.initState();

    page = widget.stateManager.page;
    totalPage = widget.stateManager.totalPage;
    widget.stateManager.setPage(page, notify: false);
  }

  @override
  void onChange() {
    resetState((update) {
      page = update<int>(
        page,
        widget.stateManager.page,
      );

      totalPage = update<int>(
        totalPage,
        widget.stateManager.totalPage,
      );
    });
  }
}

class _PlutoPaginationState extends _CustomPaginationStateWithChange {
  final Viewer settings = Get.find<DataController>().settings_data.viewer;
  late Color footerBackgroundColor = GetColor.parse(settings.footerBackgroundColor!);
  late double _maxWidth;

  bool get _isFirstPage => page < 2;
  bool get _isLastPage => page > totalPage - 1;

  int get _itemSize {
    final countItemSize = ((_maxWidth - 350) / 100).floor();
    return countItemSize < 0 ? 0 : min(countItemSize, 3);
  }

  int get _startPage {
    final itemSizeGap = _itemSize + 1;
    var start = page - itemSizeGap;
    if (page + _itemSize > totalPage) {
      start -= _itemSize + page - totalPage;
    }

    return start < 0 ? 0 : start;
  }

  int get _endPage {
    final itemSizeGap = _itemSize + 1;
    var end = page + _itemSize;

    if (page - itemSizeGap < 0) {
      end += itemSizeGap - page;
    }

    return end > totalPage ? totalPage : end;
  }

  List<int> get _pageNumbers {
    return List.generate(
      _endPage - _startPage,
      (index) => _startPage + index,
    );
  }

  void _firstPage() {
    _movePage(1);
  }

  void _beforePage() {
    setState(() {
      page -= 1 + (_itemSize * 2);

      if (page < 1) {
        page = 1;
      }

      _movePage(page);
    });
  }

  void _nextPage() {
    setState(() {
      page += 1 + (_itemSize * 2);

      if (page > totalPage) {
        page = totalPage;
      }

      _movePage(page);
    });
  }

  void _lastPage() {
    _movePage(totalPage);
  }

  void _movePage(int page) {
    widget.stateManager.setPage(page);
  }

  TextStyle _getNumberTextStyle(bool isCurrentIndex) {
    return TextStyle(
      fontSize: isCurrentIndex ? widget.stateManager.configuration!.iconSize * 0.8 : null,
      color: isCurrentIndex
          ? widget.stateManager.configuration!.activatedBorderColor
          : widget.stateManager.configuration!.iconColor,
    );
  }

  Widget _makeNumberButton(int index) {
    var pageFromIndex = index + 1;
    var isCurrentIndex = page == pageFromIndex;

    return AdwButton.flat(
      padding: EdgeInsets.fromLTRB(15, 4, 15, 4),
      constraints: BoxConstraints(
        maxHeight: 30,
        minWidth: 55,
        maxWidth: 55,
      ),
      onPressed: () {
        widget.stateManager.setPage(pageFromIndex);
      },
      margin: EdgeInsets.symmetric(vertical: 0),
      child: Text(
        pageFromIndex.toString(),
        textAlign: TextAlign.center,
        style: _getNumberTextStyle(isCurrentIndex),
      ),
    );
  }

  Color colorCheck(bool check) {
    return check ? widget.stateManager.configuration!.disabledIconColor : widget.stateManager.configuration!.iconColor;
  }

  Color backgroundCheck(bool check) {
    return check ? footerBackgroundColor  : widget.stateManager.configuration!.disabledIconColor;
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (layoutContext, size) {
        _maxWidth = size.maxWidth;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AdwButton.flat(
                  backgroundColor: backgroundCheck(_isFirstPage),
                  padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
                  constraints: BoxConstraints(maxHeight: 31, minWidth: 45, maxWidth: 45),
                  margin: EdgeInsets.symmetric(vertical: 0),
                  onPressed: _isFirstPage ? null : _firstPage,
                  child: Icon(Icons.first_page, size: 20, color: colorCheck(_isFirstPage)),
                ),
                AdwButton.flat(
                  backgroundColor: backgroundCheck(_isFirstPage),
                  padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
                  constraints: BoxConstraints(maxHeight: 31, minWidth: 45, maxWidth: 45),
                  margin: EdgeInsets.symmetric(vertical: 0),
                  onPressed: _isFirstPage ? null : _beforePage,
                  child: Icon(Icons.navigate_before, size: 20, color: colorCheck(_isFirstPage)),
                ),
                ..._pageNumbers.map(_makeNumberButton).toList(),
                AdwButton.flat(
                  backgroundColor: backgroundCheck(_isLastPage),
                  padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
                  constraints: BoxConstraints(maxHeight: 31, minWidth: 45, maxWidth: 45),
                  margin: EdgeInsets.symmetric(vertical: 0),
                  onPressed: _isLastPage ? null : _nextPage,
                  child: Icon(Icons.navigate_next, size: 20, color: colorCheck(_isLastPage)),
                ),
                AdwButton.flat(
                  backgroundColor: backgroundCheck(_isLastPage),
                  padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
                  constraints: BoxConstraints(maxHeight: 31, minWidth: 45, maxWidth: 45),
                  margin: EdgeInsets.symmetric(vertical: 0),
                  onPressed: _isLastPage ? null : _lastPage,
                  child: Icon(Icons.last_page, size: 20, color: colorCheck(_isLastPage)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

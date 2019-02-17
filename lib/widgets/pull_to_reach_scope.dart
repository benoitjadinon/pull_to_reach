import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_reach/index_calculator/index_calculator.dart';

class PullToReachScope extends InheritedWidget {
  Stream<IndexCalculation> get focusIndex => _focusIndex.stream;

  Stream<IndexCalculation> get selectIndex => _selectIndex.stream;

  Stream<double> get dragPercent => _dragPercent.stream;

  final StreamController<IndexCalculation> _focusIndex =
      StreamController.broadcast();

  final StreamController<IndexCalculation> _selectIndex =
      StreamController.broadcast();

  final StreamController<double> _dragPercent = StreamController.broadcast();

  PullToReachScope({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static PullToReachScope of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(PullToReachScope)
          as PullToReachScope;

  void setFocusIndex(IndexCalculation index) => _focusIndex.add(index);

  void setSelectIndex(IndexCalculation index) => _selectIndex.add(index);

  void setDragPercent(double percent) => _dragPercent.add(percent);

  @override
  bool updateShouldNotify(PullToReachScope old) => true;
}

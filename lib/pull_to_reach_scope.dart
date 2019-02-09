import 'dart:async';

import 'package:flutter/material.dart';

class PullToReachScope extends InheritedWidget {
  Stream<int> get focusIndex => _focusIndex.stream;

  Stream<int> get selectIndex => _selectIndex.stream;

  final StreamController<int> _focusIndex = StreamController.broadcast();
  final StreamController<int> _selectIndex = StreamController.broadcast();

  PullToReachScope({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static PullToReachScope of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(PullToReachScope)
        as PullToReachScope;
  }

  @override
  bool updateShouldNotify(PullToReachScope old) => true;

  void setFocusIndex(int index) => _focusIndex.add(index);

  void setSelectIndex(int index) => _selectIndex.add(index);
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:pull_to_reach/index_calculator/index_calculator.dart';
import 'package:pull_to_reach/widgets/pull_to_reach_scope.dart';

typedef bool IndexPredicate(int index);

@immutable
class ReachableWidget extends StatefulWidget {
  final Widget child;
  final IndexPredicate indexPredicate;

  final ValueChanged<bool> onFocusChanged;
  final VoidCallback onSelect;
  final ValueChanged<double> onOverallPercentChanged;

  ReachableWidget({
    @required this.child,
    @required this.indexPredicate,
    this.onFocusChanged,
    this.onSelect,
    this.onOverallPercentChanged,
  });

  @override
  ReachableWidgetState createState() => ReachableWidgetState();
}

class ReachableWidgetState extends State<ReachableWidget> {
  StreamSubscription<IndexCalculation> _focusSubscription;
  StreamSubscription<IndexCalculation> _selectionSubscription;
  StreamSubscription<double> _dragPercentSubscription;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didChangeDependencies() {
    _focusSubscription?.cancel();
    _selectionSubscription?.cancel();
    _dragPercentSubscription?.cancel();

    var pullToReachScope = PullToReachScope.of(context);

    _focusSubscription = pullToReachScope.focusIndex.listen(_onFocusChanged);

    _selectionSubscription =
        pullToReachScope.selectIndex.listen(_onSelectionChanged);

    _dragPercentSubscription =
        pullToReachScope.dragPercent.listen(_updateDragPercent);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusSubscription?.cancel();
    _selectionSubscription?.cancel();
    _dragPercentSubscription?.cancel();

    super.dispose();
  }

  // -----
  // Handle Notifications
  // -----

  void _onFocusChanged(IndexCalculation newIndex) {
    if (widget.onFocusChanged == null) return;
    widget.onFocusChanged(widget.indexPredicate(newIndex.index));
  }

  void _onSelectionChanged(IndexCalculation newIndex) {
    if (widget.onSelect == null) return;
    if (widget.indexPredicate(newIndex.index)) widget.onSelect();
  }

  void _updateDragPercent(double percent) {
    if (widget.onOverallPercentChanged == null) return;
    widget.onOverallPercentChanged(percent);
  }
}

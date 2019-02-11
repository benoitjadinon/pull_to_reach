import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:pull_down_to_reach/index_calculator/index_calculator.dart';
import 'package:pull_down_to_reach/widgets/pull_to_reach_scope.dart';

@immutable
class ReachableWidget extends StatefulWidget {
  final Widget child;
  final int index;

  final ValueChanged<bool> onFocusChanged;
  final VoidCallback onSelect;
  final ValueChanged<double> onOverallPercentChanged;

  ReachableWidget({
    @required this.child,
    @required this.index,
    this.onFocusChanged,
    this.onSelect,
    this.onOverallPercentChanged,
  });

  @override
  ReachableWidgetState createState() => ReachableWidgetState();
}

class ReachableWidgetState extends State<ReachableWidget> {
  int _lastFocusIndex = -1;

  StreamSubscription<IndexCalculation> _focusSubscription;
  StreamSubscription<IndexCalculation> _selectionSubscription;

  @override
  void didChangeDependencies() {
    _focusSubscription?.cancel();
    _selectionSubscription?.cancel();

    _focusSubscription =
        PullToReachScope.of(context).focusIndex.listen(_onFocusChanged);

    _selectionSubscription =
        PullToReachScope.of(context).selectIndex.listen(_onSelectionChanged);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _focusSubscription?.cancel();
    _selectionSubscription?.cancel();
    super.dispose();
  }

  // -----
  // Handle Notifications
  // -----

  void _onFocusChanged(IndexCalculation indexCalculation) {
    _updatePercent(indexCalculation.overallPercent);

    var newIndex = indexCalculation.index;
    var ownIndex = widget.index;

    if (widget.onFocusChanged == null) return;

    var isNowFocused = newIndex == ownIndex;
    var wasFocused = _lastFocusIndex == ownIndex;

    if (!wasFocused && isNowFocused) {
      widget.onFocusChanged(true);
    }

    if (wasFocused && !isNowFocused) {
      widget.onFocusChanged(false);
    }

    _lastFocusIndex = newIndex;
  }

  void _onSelectionChanged(IndexCalculation indexCalculation) {
    _updatePercent(indexCalculation.overallPercent);

    var newIndex = indexCalculation.index;
    var ownIndex = widget.index;

    if (widget.onSelect == null) return;
    if (newIndex == ownIndex && widget.onSelect != null) {
      widget.onSelect();
    }
  }

  void _updatePercent(double overallPercent) {
    if (widget.onOverallPercentChanged == null) return;
    widget.onOverallPercentChanged(overallPercent);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:pull_to_reach/widgets/pull_to_reach_scope.dart';

typedef bool IndexPredicate(int index);

@immutable
class Reachable extends StatefulWidget {
  final Widget child;
  final IndexPredicate indexPredicate;

  final ValueChanged<bool> onFocusChanged;
  final VoidCallback onSelect;
  final ValueChanged<double> onOverallPercentChanged;

  Reachable({
    @required this.child,
    @required this.indexPredicate,
    this.onFocusChanged,
    this.onSelect,
    this.onOverallPercentChanged,
  });

  @override
  ReachableState createState() => ReachableState();
}

class ReachableState extends State<Reachable> {
  StreamSubscription<int> _focusSubscription;
  StreamSubscription<int> _selectionSubscription;
  StreamSubscription<double> _dragPercentSubscription;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didChangeDependencies() {
    _focusSubscription?.cancel();
    _selectionSubscription?.cancel();
    _dragPercentSubscription?.cancel();

    var pullToReachContext = PullToReachContext.of(context);

    _focusSubscription = pullToReachContext.focusIndex.listen(_onFocusChanged);

    _selectionSubscription =
        pullToReachContext.selectIndex.listen(_onSelectionChanged);

    _dragPercentSubscription =
        pullToReachContext.dragPercent.listen(_updateDragPercent);

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

  void _onFocusChanged(int newIndex) {
    if (widget.onFocusChanged == null) return;
    widget.onFocusChanged(widget.indexPredicate(newIndex));
  }

  void _onSelectionChanged(int newIndex) {
    if (widget.onSelect == null) return;
    if (widget.indexPredicate(newIndex)) widget.onSelect();
  }

  void _updateDragPercent(double percent) {
    if (widget.onOverallPercentChanged == null) return;
    widget.onOverallPercentChanged(percent);
  }
}

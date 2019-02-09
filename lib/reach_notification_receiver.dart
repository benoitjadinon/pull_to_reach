import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:pull_down_to_reach/pull_to_reach_scope.dart';

@immutable
class ReachNotificationReceiver extends StatefulWidget {
  final Widget child;
  final int index;

  final ValueChanged<bool> onFocusChanged;
  final VoidCallback onSelect;

  ReachNotificationReceiver({
    @required this.child,
    @required this.index,
    this.onFocusChanged,
    this.onSelect,
  });

  @override
  ReachNotificationReceiverState createState() =>
      ReachNotificationReceiverState();
}

class ReachNotificationReceiverState extends State<ReachNotificationReceiver> {
  int _lastFocusIndex = -1;

  StreamSubscription<int> _focusSubscription;
  StreamSubscription<int> _selectionSubscription;

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

  void _onFocusChanged(int newIndex) {
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

  void _onSelectionChanged(int newIndex) {
    var ownIndex = widget.index;

    if (widget.onSelect == null) return;
    if (newIndex == ownIndex && widget.onSelect != null) {
      widget.onSelect();
    }
  }
}

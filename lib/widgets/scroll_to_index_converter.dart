import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_down_to_reach/index_calculator/index_calculator.dart';
import 'package:pull_down_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_down_to_reach/widgets/pull_to_reach_scope.dart';

class ScrollToIndexConverter extends StatefulWidget {
  final Widget child;
  final List<WeightedIndex> items;

  final double dragExtentPercentage;

  ScrollToIndexConverter({
    @required this.child,
    @required this.items,
    this.dragExtentPercentage = 0.5,
  });

  @override
  _ScrollToIndexConverterState createState() => _ScrollToIndexConverterState();
}

class _ScrollToIndexConverterState extends State<ScrollToIndexConverter>
    with TickerProviderStateMixin {
  double _dragOffset = 0;
  IndexCalculation _currentIndex = IndexCalculation.empty();

  bool _pullToReachStarted = false;
  bool _shouldNotifyOnDragEnd = false;

  //TODO add index calculator to ScrollToIndexConverter
  IndexCalculator indexCalculator;

  @override
  void initState() {
    indexCalculator = IndexCalculator(indices: widget.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );
  }

  // -----
  // Handle notifications
  // -----

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_didDragStart(notification)) {
      _dragOffset = 0;
      _pullToReachStarted = true;
    }

    if (_didDragEnd(notification)) {
      _dragOffset = 0;
      _pullToReachStarted = false;

      _notifySelectIfNeeded();
    }

    if (_pullToReachStarted) {
      _shouldNotifyOnDragEnd = true;
    } else {
      return false;
    }

    var progress = _calculateScrollProgress(notification);
    var index = indexCalculator.getIndexForScrollPercent(progress);
    _updateScrollPercent(progress);

    if (_currentIndex != index) {
      _currentIndex = index;
      _updateFocusIndex();
    }

    return false;
  }

  bool _didDragStart(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.metrics.extentBefore == 0) {
      return true;
    }

    return false;
  }

  bool _didDragEnd(ScrollNotification notification) {
    if (notification.metrics.extentBefore > 0) return false;

    // Whenever dragDetails are null the scrolling happened without users input
    // meaning that the user release the finger --> drag has ended.
    // For Cupertino Scrollables the ScrollEndNotification can not be used
    // since it will be send after the list scroll has completely ended and
    // the list is in its initial state
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails == null) {
      return true;
    }

    // For Material Scrollables we can simply use the ScrollEndNotification
    if (notification is ScrollEndNotification) {
      return true;
    }

    return false;
  }

  double _calculateScrollProgress(ScrollNotification notification) {
    var containerExtent = notification.metrics.viewportDimension;

    // reset drag offset since user is scrolling down
    if (notification.metrics.extentBefore > 0.0) {
      _dragOffset = 0;
      return 0;
    }

    if (notification is ScrollUpdateNotification) {
      _dragOffset -= notification.scrollDelta / 0.8;
    }

    if (notification is OverscrollNotification) {
      _dragOffset -= notification.overscroll / 0.8;
    }

    var newValue =
        _dragOffset / (containerExtent * widget.dragExtentPercentage);

    return newValue.clamp(0.0, 1.0);
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) return false;

    notification.disallowGlow();
    return false;
  }

  // -----
  // PullToReachScope updates
  // -----

  void _notifySelectIfNeeded() {
    if (_shouldNotifyOnDragEnd) {
      PullToReachScope.of(context).setSelectIndex(_currentIndex);
      PullToReachScope.of(context).setDragPercent(0);
      PullToReachScope.of(context).setFocusIndex(IndexCalculation.empty());

      _shouldNotifyOnDragEnd = false;
    }
  }

  void _updateFocusIndex() {
    PullToReachScope.of(context).setFocusIndex(_currentIndex);
  }

  void _updateScrollPercent(double percent) {
    PullToReachScope.of(context).setDragPercent(percent);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_down_to_reach/index_calculator/index_calculator.dart';
import 'package:pull_down_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_down_to_reach/widgets/pull_to_reach_scope.dart';
import 'package:pull_down_to_reach/widgets/reachable_item.dart';

class PullToReachList extends StatefulWidget {
  final Widget child;
  final List<ReachableItem> items;
  final double instructionTextWeight;

  // How much the scroll's drag gesture can overshoot
  final double overshootLimit;

  // The over-scroll distance that moves the info text to its maximum
  // displacement, as a percentage of the scrollable's container extent.
  final double dragExtentPercentage;

  PullToReachList({
    @required this.child,
    @required this.items,
    this.instructionTextWeight = 2.2,
    this.overshootLimit = 1.2,
    this.dragExtentPercentage = 0.5,
  });

  @override
  _PullToReachListState createState() => _PullToReachListState();
}

class _PullToReachListState extends State<PullToReachList>
    with TickerProviderStateMixin {
  AnimationController _positionController;

  double _dragOffset = 0;
  int _itemIndex = 0;

  bool _shouldNotify = false;

  IndexCalculator indexCalculator;

  @override
  void initState() {
    indexCalculator = IndexCalculator.withIndices(
      minScrollPosition: 0,
      maxScrollPosition: 1,
      indices: _createWeightedIndices(widget.items),
    );

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

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  // -----
  // Handle notifications
  // -----

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_didDragEnd(notification)) {
      if (_shouldNotify) {
        _updateSelectIndex();
        _shouldNotify = false;
      }
    } else {
      _shouldNotify = true;
    }

    var progress = _calculateScrollProgress(notification);
    var index = indexCalculator.getItemIndexForPosition(progress);

    if (_itemIndex != index) {
      setState(() => _itemIndex = index);
      _updateFocusIndex();
    }

    _positionController.value = progress;
    return false;
  }

  bool _didDragEnd(ScrollNotification notification) {
    if (notification.metrics.extentBefore > 0) return false;

    // whenever dragDetails are null the scrolling happened without users input
    // meaning that the user release the finger
    // in this case the drag has ended
    // for Cupertino Scrollables the ScrollEndNotification can not be used
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

  void _updateSelectIndex() {
    PullToReachScope.of(context).setSelectIndex(_itemIndex);
  }

  void _updateFocusIndex() {
    PullToReachScope.of(context).setFocusIndex(_itemIndex);
  }

  // -----
  // Helper
  // -----

  List<WeightedIndex> _createWeightedIndices(List<ReachableItem> items) {
    List<WeightedIndex> indices = List();

    for (int i = 0; i < items.length; i++) {
      indices.add(WeightedIndex(
        index: i,
        weight: items[i].weight,
      ));
    }

    return indices;
  }
}

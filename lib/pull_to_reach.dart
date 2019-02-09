import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_down_to_reach/pull_to_reach_scope.dart';
import 'package:pull_down_to_reach/reachable_index_calculator.dart';
import 'package:pull_down_to_reach/reachable_item.dart';

class PullToReach extends StatefulWidget {
  final Widget child;
  final List<ReachableItem> items;
  final double instructionTextWeight;

  // How much the scroll's drag gesture can overshoot
  final double overshootLimit;

  // The over-scroll distance that moves the info text to its maximum
  // displacement, as a percentage of the scrollable's container extent.
  final double dragExtentPercentage;

  PullToReach({
    @required this.child,
    @required this.items,
    this.instructionTextWeight = 2.2,
    this.overshootLimit = 1.2,
    this.dragExtentPercentage = 0.5,
  });

  @override
  _PullToReachState createState() => _PullToReachState();
}

class _PullToReachState extends State<PullToReach>
    with TickerProviderStateMixin {
  AnimationController _positionController;
  Animation<double> _positionFactor;

  double _dragOffset = 0;
  int _itemIndex = 0;

  bool _shouldNotify = false;

  ReachableIndexCalculator indexCalculator;

  @override
  void initState() {
    _positionController = AnimationController(vsync: this);

    _positionFactor = _positionController.drive(
      Tween<double>(
        begin: 0.0,
        end: widget.overshootLimit,
      ),
    )..addListener(() => _checkItemSelection(_positionFactor.value));

    indexCalculator = ReachableIndexCalculator.withIndices(
      minScrollPosition: 0,
      maxScrollPosition: 1,
      indices: _createWeightedIndices(widget.items),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _positionFactor,
          builder: (context, _) {
            var safePadding = MediaQuery.of(context).padding.top;
            var padding = 64.0;

            return Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(
                top: (padding * _positionFactor.value) + safePadding,
              ),
              child: Text(
                widget.items[_itemIndex].text,
                style: Theme.of(context)
                    .primaryTextTheme
                    .title
                    .copyWith(color: Colors.black54),
              ),
            );
          },
          child: Container(),
        ),
        child
      ],
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

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) return false;

    notification.disallowGlow();
    return false;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // whenever dragDetails are null the scrolling happened without users input
      // meaning that the user release the finger
      // in this case we want to fire the currently selected item index
      if (notification.dragDetails == null) {
        _updateSelectIndex();
      }
      // dragging is done by the user, notify on the next release
      else {
        _shouldNotify = true;
      }

      // user is scrolling down
      if (notification.metrics.extentBefore > 0.0) {
        _resetDragOffset();
      } else {
        _dragOffset -= notification.scrollDelta;
        _checkDragOffset(notification.metrics.viewportDimension);
      }

      if (notification is OverscrollNotification) {
        _dragOffset -= (notification as OverscrollNotification).overscroll;
        _checkDragOffset(notification.metrics.viewportDimension);

        return false;
      }
    }

    return false;
  }

  void _checkDragOffset(double containerExtent) {
    double newValue =
        _dragOffset / (containerExtent * widget.dragExtentPercentage);

    _positionController.value = newValue.clamp(0.0, 1.0);
  }

  void _checkItemSelection(double progress) {
    var index = indexCalculator.getItemIndexForPosition(progress);
    if (_itemIndex != index) {
      _itemIndex = index;
      _updateFocusIndex();
    }
  }

  void _resetDragOffset() {
    _dragOffset = 0;
  }

  // -----
  // PullToReachScope updates
  // -----

  void _updateSelectIndex() {
    if (_shouldNotify == false) return;

    PullToReachScope.of(context).setSelectIndex(_itemIndex);
    _shouldNotify = false;
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_down_to_reach/reachable_index_calculator.dart';

class PullToReachItem {
  final String text;

  PullToReachItem(this.text);
}

class PullToReach extends StatefulWidget {
  final Widget child;
  final List<PullToReachItem> items;

  // How much the scroll's drag gesture can overshoot
  final double overshootLimit;

  // The over-scroll distance that moves the info text to its maximum
  // displacement, as a percentage of the scrollable's container extent.
  final double dragExtentPercentage;

  PullToReach({
    @required this.child,
    @required this.items,
    this.overshootLimit = 2,
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

    indexCalculator = ReachableIndexCalculator(
      minScrollPosition: 0,
      maxScrollPosition: widget.overshootLimit,
      itemCount: widget.items.length,
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
            var padding = 8.0;

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
  void didChangeDependencies() {
    // TODO check and adjust theming if needed
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) return false;

    notification.disallowGlow();
    return false;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.extentBefore > 0.0) {
        _dismiss();
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
    var index = indexCalculator.getItemIndex(progress);
    if (_itemIndex != index) {
      _itemIndex = index;
      //TODO send notification
    }
  }

  void _dismiss() {
    _dragOffset = 0;
  }
}

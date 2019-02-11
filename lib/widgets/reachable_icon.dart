import 'package:flutter/material.dart';
import 'package:pull_down_to_reach/widgets/reachable_widget.dart';

class ReachableIcon extends StatefulWidget {
  final Widget child;
  final int index;
  final double size;
  final VoidCallback onSelect;
  final Duration duration;

  ReachableIcon(
      {@required this.child,
      @required this.index,
      this.size = 24,
      @required this.onSelect,
      this.duration = const Duration(milliseconds: 100)});

  @override
  _ReachableIconState createState() => _ReachableIconState();
}

class _ReachableIconState extends State<ReachableIcon>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _iconScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 1, end: 1.2));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReachableWidget(
      index: widget.index,
      onSelect: widget.onSelect,
      onFocusChanged: (isFocused) {
        if (isFocused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return IconButton(
            icon: widget.child,
            onPressed: widget.onSelect,
            iconSize: _iconScaleAnimation.value * widget.size,
          );
        },
        child: Container(),
      ),
    );
  }
}

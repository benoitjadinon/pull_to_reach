import 'package:flutter/material.dart';
import 'package:pull_to_reach/widgets/highlighter.dart';
import 'package:pull_to_reach/widgets/reachable.dart';

class ReachableIcon extends StatefulWidget {
  final Widget icon;
  final int index;
  final VoidCallback onSelect;

  final Duration duration;
  final EdgeInsets padding;
  final double scaleFactor;

  final WidgetBuilder focusBuilder;

  ReachableIcon(
      {@required this.icon,
      @required this.index,
      @required this.onSelect,
      this.padding = const EdgeInsets.all(8),
      this.duration = const Duration(milliseconds: 100),
      this.scaleFactor = 1.25,
      this.focusBuilder});

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
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetBuilder builder = (context) {
      return ScaleTransition(
        scale: _iconScaleAnimation.drive(Tween(
          begin: 1,
          end: widget.scaleFactor,
        )),
        child: InkResponse(
          onTap: widget.onSelect,
          child: Container(
            margin: widget.padding,
            child: widget.icon,
          ),
        ),
      );
    };

    WidgetBuilder focusBuilder = widget.focusBuilder ?? builder;

    return Reachable(
      index: widget.index,
      onSelect: () {
        Highlighter.of(context).removeHighlight();
        widget.onSelect();
      },
      onFocusChanged: (isFocused) {
        if (isFocused) {
          Highlighter.of(context).highlight(context, focusBuilder);
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: builder(context),
    );
  }
}

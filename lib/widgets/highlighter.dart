import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_reach/curve/soft_bounce_curve.dart';

class Highlighter extends StatefulWidget {
  final Widget child;
  final double sizeFactor;
  final double opacity;

  final Duration positionDuration;
  final Curve positionCurve;

  final Duration scaleDuration;
  final Curve scaleCurve;

  Highlighter(
      {@required this.child,
      this.sizeFactor = 1.25,
      this.opacity = 0.5,
      this.positionDuration = const Duration(milliseconds: 250),
      this.positionCurve = const SoftBounceOut(),
      this.scaleDuration = const Duration(milliseconds: 250),
      this.scaleCurve = Curves.easeOut});

  @override
  HighlighterState createState() => HighlighterState();

  static HighlighterState of(BuildContext context) {
    var state = context.ancestorStateOfType(
      const TypeMatcher<HighlighterState>(),
    );

    if (state == null) {
      throw FlutterError(
        'HighlighterState.of() called '
            'with a context that does not contain a Highlighter.\n',
      );
    }

    return state;
  }
}

class HighlighterState extends State<Highlighter> {
  double _size = 24;
  double _opacity = 0;
  Offset _center = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      AnimatedPositioned(
        left: _center.dx - _size / 2,
        top: _center.dy - _size / 2,
        curve: widget.positionCurve,
        child: AnimatedContainer(
          curve: widget.scaleCurve,
          decoration: BoxDecoration(
            color: Colors.black45.withOpacity(_opacity),
            shape: BoxShape.circle,
          ),
          height: _size,
          width: _size,
          duration: widget.scaleDuration,
        ),
        duration: widget.positionDuration,
      )
    ]);
  }

  // -----
  // Public Api
  // -----

  void highlight(BuildContext widgetContext) {
    var box = widgetContext.findRenderObject() as RenderBox;

    var size = max(box.size.width, box.size.height);
    var center = box.size.center(box.localToGlobal(Offset(0.0, 0.0)));

    if (_opacity == 0) _center = center;

    setState(() {
      _size = size;
      _center = center;
      _opacity = widget.opacity;
    });
  }

  void removeHighlight() {
    setState(() {
      _size = _size * widget.sizeFactor;
      _opacity = 0;
    });
  }
}

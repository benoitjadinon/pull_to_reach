import 'package:flutter/animation.dart';

class SoftBounceOut extends Curve {
  const SoftBounceOut();

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    return _bounce(t);
  }
}

double _bounce(double t) {
  var divideRatio = 2.75;

  if (t < 1.0 / divideRatio) {
    return 7.5625 * t * t;
  } else if (t < 2 / divideRatio) {
    t -= 1.5 / divideRatio;
    return 7.5625 * t * t + 0.75;
  } else if (t < 2.5 / divideRatio) {
    t -= 2.25 / divideRatio;
    return 7.5625 * t * t + 0.9375;
  }
  t -= 2.625 / divideRatio;
  return 7.5625 * t * t + 0.984375;
}

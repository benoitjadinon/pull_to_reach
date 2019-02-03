import 'package:meta/meta.dart';
import 'package:pull_down_to_reach/range.dart';

abstract class ReachableIndexCalculator {
  int getItemIndex(double scrollPosition);

  factory ReachableIndexCalculator({
    @required double minScrollPosition,
    @required double maxScrollPosition,
    @required int itemCount,
  }) =>
      _ReachableIndexCalculatorImpl(
        minScrollPosition,
        maxScrollPosition,
        itemCount,
      );
}

class _ReachableIndexCalculatorImpl implements ReachableIndexCalculator {
  final double minScrollPosition;
  final double maxScrollPosition;

  final int itemCount;

  List<Range> _ranges;

  _ReachableIndexCalculatorImpl(
    this.minScrollPosition,
    this.maxScrollPosition,
    this.itemCount,
  ) : _ranges = _createRanges(itemCount, minScrollPosition, maxScrollPosition);

  @override
  int getItemIndex(double scrollPosition) {
    var range = _ranges.firstWhere(
      (range) => range.isInRange(scrollPosition),
      orElse: () => null,
    );

    return range?.index ?? -1;
  }

  // -----
  // Initializer
  // -----

  static List<Range> _createRanges(int count, double min, double max) {
    var ranges = List<Range>();
    var rangeSize = max / count;

    for (int i = 0; i <= count; i++) {
      var isFirst = i == 0;
      var isLast = i == count - 1;

      var start = isFirst ? double.negativeInfinity : i.toDouble() * rangeSize;
      var end =
          isLast ? double.infinity : (i.toDouble() * rangeSize) + rangeSize;

      ranges.add(
        Range(i, start, end),
      );
    }

    return ranges;
  }
}

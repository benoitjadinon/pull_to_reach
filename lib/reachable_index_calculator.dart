import 'package:meta/meta.dart';
import 'package:pull_down_to_reach/range.dart';
import 'package:pull_down_to_reach/util.dart';

@immutable
class WeightedIndex {
  final int index;
  final double weight;

  WeightedIndex({
    @required this.index,
    @required this.weight,
  });
}

abstract class ReachableIndexCalculator {
  int getItemIndexForPosition(double scrollPosition);

  // -----
  // Factories
  // -----

  static ReachableIndexCalculator withCount({
    @required double minScrollPosition,
    @required double maxScrollPosition,
    @required int itemCount,
  }) =>
      _ReachableIndexCalculatorImpl(
        minScrollPosition,
        maxScrollPosition,
        mapIndex(
            end: itemCount,
            mapper: (index) => WeightedIndex(
                  index: index,
                  weight: 1,
                )),
      );

  static ReachableIndexCalculator withIndices({
    @required double minScrollPosition,
    @required double maxScrollPosition,
    @required List<WeightedIndex> indices,
  }) =>
      _ReachableIndexCalculatorImpl(
        minScrollPosition,
        maxScrollPosition,
        indices,
      );
}

class _ReachableIndexCalculatorImpl implements ReachableIndexCalculator {
  final double minScrollPosition;
  final double maxScrollPosition;

  final List<WeightedIndex> indices;
  List<Range> _ranges;

  _ReachableIndexCalculatorImpl(
      this.minScrollPosition, this.maxScrollPosition, this.indices) {
    _ranges = _createRanges(indices, minScrollPosition, maxScrollPosition);
  }

  @override
  int getItemIndexForPosition(double scrollPosition) {
    var range = _ranges.firstWhere(
      (range) => range.isInRange(scrollPosition),
      orElse: () => null,
    );

    return range?.index ?? -1;
  }

  List<Range> _createRanges(
      List<WeightedIndex> indices, double min, double max) {
    var count = indices.length;

    var ranges = List<Range>();

    double previousEnd = 0;
    for (int i = 0; i < count; i++) {
      var isFirst = i == 0;
      var isLast = i == count - 1;

      var currentIndex = indices[i];

      double start;
      if (isFirst) {
        start = double.negativeInfinity;
      } else {
        start = previousEnd;
      }

      double end;
      if (isLast) {
        end = double.infinity;
      } else {
        var rangeSize = _rangeSizeForIndex(
          index: currentIndex,
          other: indices,
          maxValue: maxScrollPosition,
        );

        end = previousEnd + rangeSize;
      }

      print(
          "${currentIndex.index}: from: $start to: $end. diff: ${end - start}");
      ranges.add(
        Range(currentIndex.index, start, end),
      );

      previousEnd = end;
    }

    return ranges;
  }

  double _rangeSizeForIndex(
      {WeightedIndex index, List<WeightedIndex> other, double maxValue}) {
    var weightSum = sum<WeightedIndex>(
      items: other,
      mapper: (index) => index.weight,
    );

    var weightPercent = weightSum / index.weight;
    return maxValue / weightPercent;
  }
}

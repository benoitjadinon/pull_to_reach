import 'package:meta/meta.dart';
import 'package:pull_down_to_reach/index_calculator/range.dart';
import 'package:pull_down_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_down_to_reach/util.dart';

abstract class IndexCalculator {
  int getItemIndexForPosition(double scrollPosition);

  // -----
  // Factories
  // -----

  static IndexCalculator withCount({
    @required double minScrollPosition,
    @required double maxScrollPosition,
    @required int itemCount,
  }) =>
      _IndexCalculatorImpl(
        minScrollPosition,
        maxScrollPosition,
        mapIndex(
            end: itemCount,
            mapper: (index) => WeightedIndex(
                  index: index,
                  weight: 1,
                )),
      );

  static IndexCalculator withIndices({
    @required double minScrollPosition,
    @required double maxScrollPosition,
    @required List<WeightedIndex> indices,
  }) =>
      _IndexCalculatorImpl(
        minScrollPosition,
        maxScrollPosition,
        indices,
      );
}

class _IndexCalculatorImpl implements IndexCalculator {
  final double minScrollPosition;
  final double maxScrollPosition;

  final List<WeightedIndex> indices;
  List<Range> _ranges;

  _IndexCalculatorImpl(
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

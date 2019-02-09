import 'package:pull_down_to_reach/index_calculator/index_calculator.dart';
import 'package:pull_down_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_down_to_reach/util.dart';
import 'package:test_api/test_api.dart';

void main() {
  var createNotifier = () {
    return IndexCalculator(
      minScrollPosition: 0,
      maxScrollPosition: 4,
      indices:
          mapIndex(end: 4, mapper: (i) => WeightedIndex(index: i, weight: 1)),
    );
  };

  test('negative value returns first index', () {
    expect(createNotifier().getIndexForScrollPercent(-1.2), 0);
  });

  test('bigger value always returns last index', () {
    expect(createNotifier().getIndexForScrollPercent(5), 3);
  });

  test('value in range returns correct index', () {
    expect(createNotifier().getIndexForScrollPercent(0.1), 0);
    expect(createNotifier().getIndexForScrollPercent(0.9), 0);

    expect(createNotifier().getIndexForScrollPercent(1.1), 1);
    expect(createNotifier().getIndexForScrollPercent(1.9), 1);

    expect(createNotifier().getIndexForScrollPercent(2.1), 2);
    expect(createNotifier().getIndexForScrollPercent(2.9), 2);

    expect(createNotifier().getIndexForScrollPercent(3.1), 3);
    expect(createNotifier().getIndexForScrollPercent(3.9), 3);
  });

  test('twice as much weight results in twice as much range', () {
    var itemNotifier = IndexCalculator(
      minScrollPosition: 0,
      maxScrollPosition: 7,
      indices: [
        WeightedIndex(index: 1, weight: 1),
        WeightedIndex(index: 2, weight: 1),
        WeightedIndex(index: 3, weight: 1),
        WeightedIndex(index: 4, weight: 5),
        WeightedIndex(index: 5, weight: 1),
        WeightedIndex(index: 6, weight: 1),
        WeightedIndex(index: 7, weight: 1),
      ],
    );

    expect(itemNotifier.getIndexForScrollPercent(5), 4);
  });
}

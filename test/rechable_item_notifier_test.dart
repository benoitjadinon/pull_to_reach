import 'package:pull_down_to_reach/reachable_index_calculator.dart';
import 'package:test_api/test_api.dart';

void main() {
  ReachableIndexCalculator itemNotifier;

  setUp(() {
    itemNotifier = ReachableIndexCalculator(
      minScrollPosition: 0,
      maxScrollPosition: 4,
      itemCount: 4,
    );
  });

  test('negative value returns first index', () {
    expect(itemNotifier.getItemIndex(-1.2), 0);
  });

  test('bigger value always returns last index', () {
    expect(itemNotifier.getItemIndex(5), 3);
  });

  test('value in range returns correct index', () {
    expect(itemNotifier.getItemIndex(0.1), 0);
    expect(itemNotifier.getItemIndex(0.9), 0);

    expect(itemNotifier.getItemIndex(1.1), 1);
    expect(itemNotifier.getItemIndex(1.9), 1);

    expect(itemNotifier.getItemIndex(2.1), 2);
    expect(itemNotifier.getItemIndex(2.9), 2);

    expect(itemNotifier.getItemIndex(3.1), 3);
    expect(itemNotifier.getItemIndex(3.9), 3);
  });
}

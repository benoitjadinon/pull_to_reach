import 'package:meta/meta.dart';

class ReachableItem {
  final String text;
  final double weight;

  ReachableItem({
    @required this.text,
    this.weight = 1,
  });
}

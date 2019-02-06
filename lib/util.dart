import 'package:meta/meta.dart';

List<R> mapIndex<R>({
  int start = 0,
  @required int end,
  @required R Function(int) mapper,
}) {
  List<R> result = List();

  for (int i = start; i < end; i++) {
    result.add(mapper(i));
  }

  return result;
}

double sum<T>({@required List<T> items, @required double Function(T) mapper}) {
  double sum = 0;
  items.forEach((item) => sum += mapper(item));
  return sum;
}

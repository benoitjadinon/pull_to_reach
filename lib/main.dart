import 'package:flutter/material.dart';
import 'package:pull_down_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_down_to_reach/widgets/pull_to_reach_scope.dart';
import 'package:pull_down_to_reach/widgets/reachable_icon.dart';
import 'package:pull_down_to_reach/widgets/scroll_to_index_converter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return PullToReachScope(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text("Pull down!"),
          actions: [
            ReachableIcon(
              child: Icon(Icons.search),
              index: 2,
              onSelect: () => _showPage("search!"),
            ),
            ReachableIcon(
                child: Icon(Icons.settings),
                index: 1,
                onSelect: () => _showPage("settings!")),
          ],
        ),
        body: ScrollToIndexConverter(
          items: [
            WeightedIndex(index: 0, weight: 1.5),
            WeightedIndex(index: 1),
            WeightedIndex(index: 2),
            WeightedIndex(index: 3),
          ],
          child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return Container(
                  height: 50,
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('list item $index'),
                );
              }),
        ),
      ),
    );
  }

  void _showPage(String text) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        var titleTheme = Theme.of(context)
            .primaryTextTheme
            .title
            .copyWith(color: Colors.black45);

        return Scaffold(
            appBar: AppBar(title: Text(text)),
            body: Center(child: Text(text, style: titleTheme)));
      },
    ));
  }
}

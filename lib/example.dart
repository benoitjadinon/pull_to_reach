import 'package:flutter/material.dart';
import 'package:pull_to_reach/index_calculator/index_calculator.dart';
import 'package:pull_to_reach/index_calculator/weighted_index.dart';
import 'package:pull_to_reach/widgets/pull_to_reach_scope.dart';
import 'package:pull_to_reach/widgets/reachable.dart';
import 'package:pull_to_reach/widgets/reachable_icon.dart';
import 'package:pull_to_reach/widgets/scroll_to_index_converter.dart';

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
              icon: Icon(Icons.search),
              index: 2,
              onSelect: () => _showPage("search!"),
            ),
            ReachableIcon(
                icon: Icon(Icons.settings),
                index: 1,
                onSelect: () => _showPage("settings!")),
          ],
        ),
        body: ScrollToIndexConverter(
          items: [
            WeightedIndex(index: 0, weight: 1.5),
            WeightedIndex(index: 1),
            WeightedIndex(index: 2),
          ],
          child: Stack(
            children: [
              ListView.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 50,
                      alignment: Alignment.center,
                      color: Colors.lightBlue[100 * (index % 9)],
                      child: Text('list item $index'),
                    );
                  }),
              Align(
                child: InstructionText(
                  instructionText: [
                    "Pull down to reach!",
                    "Release for settings",
                    "Release for search",
                  ],
                ),
                alignment: Alignment.topCenter,
              )
            ],
          ),
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

class InstructionText extends StatefulWidget {
  final List<String> instructionText;

  InstructionText({@required this.instructionText});

  @override
  _InstructionTextState createState() => _InstructionTextState();
}

class _InstructionTextState extends State<InstructionText> {
  double _percent = 0;

  @override
  Widget build(BuildContext context) {
    return Reachable(
      indexPredicate: (index) => true,
      onOverallPercentChanged: (percent) => setState(() => _percent = percent),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: _percent > 0 ? 1 : 0,
        child: Container(
          margin: EdgeInsets.only(top: 16 + (64 * _percent)),
          child: Card(
            elevation: 12,
            child: Container(
              padding: EdgeInsets.all(16),
              child: StreamBuilder<String>(
                  stream: PullToReachScope.of(context)
                      .focusIndex
                      .map(_stringForIndex),
                  builder: (context, snapshot) {
                    var string = snapshot.data ?? "Pull down!";
                    return Text(
                      string,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .title
                          .copyWith(color: Colors.black45),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  String _stringForIndex(IndexCalculation event) {
    return widget.instructionText[event.index];
  }
}

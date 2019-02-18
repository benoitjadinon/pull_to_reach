import 'package:flutter/material.dart';
import 'package:pull_to_reach/pull_to_reach.dart';
import 'package:pull_to_reach/reachable_feedback.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: TestPage(),
      );
}

class TestPage extends StatefulWidget {
  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final ReachableFeedback feedback = HapticReachableFeedback(
      shouldVibrateOnFocus: (index) => index > 0,
      shouldVibrateOnSelect: (index) => index > 0);

  @override
  Widget build(BuildContext context) {
    return PullToReachContext(
      indexCount: 4,
      onFocusChanged: feedback.onFocus,
      onSelectChanged: feedback.onSelect,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        body: ScrollToIndexConverter(
          child: _buildList(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        actions: [
          ReachableIcon(
            icon: Icon(Icons.refresh),
            index: 3,
            onSelect: () => _showMessage("Refreshing..."),
          ),
          ReachableIcon(
            icon: Icon(Icons.search),
            index: 2,
            onSelect: () => _showMessage("search!"),
          ),
          ReachableIcon(
              icon: Icon(Icons.settings),
              index: 1,
              onSelect: () => _showMessage("settings!")),
        ],
      );

  Widget _buildList() => ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        return Container(
          height: 50,
          alignment: Alignment.center,
          color: Colors.lightBlue[100 * (index % 9)],
          child: Text('list item $index'),
        );
      });

  void _showMessage(String text) =>
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(text),
        duration: Duration(
          seconds: 1,
        ),
      ));
}

/*
 *
 * class MyApp extends StatelessWidget {
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

  String _stringForIndex(int index) {
    return widget.instructionText[index];
  }
}
 */

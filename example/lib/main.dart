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
          child: Stack(
            children: [
              _buildList(),
              Align(
                alignment: Alignment.topCenter,
                child: InstructionText(instructionText: [
                  "Pull down!",
                  "Release for settings",
                  "Release to search",
                  "Release to refresh",
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    var iconColor = Theme.of(context).primaryTextTheme.title.color;
    return AppBar(
      actions: [
        ReachableIcon(
          builder: (context) => Icon(Icons.refresh, color: iconColor),
          index: 3,
          onSelect: () => _showMessage("Refreshing..."),
        ),
        ReachableIcon(
          builder: (context) => Icon(Icons.search, color: iconColor),
          index: 2,
          onSelect: () => _showMessage("search!"),
        ),
        ReachableIcon(
            builder: (context) => Icon(Icons.settings, color: iconColor),
            index: 1,
            onSelect: () => _showMessage("settings!")),
      ],
    );
  }

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

class InstructionText extends StatefulWidget {
  final List<String> instructionText;

  InstructionText({@required this.instructionText});

  @override
  _InstructionTextState createState() => _InstructionTextState();
}

class _InstructionTextState extends State<InstructionText> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
        stream: PullToReachContext.of(context).dragPercent,
        builder: (context, snapshot) {
          var percent = snapshot.data ?? 0.0;

          return AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: percent > 0 ? 1 : 0,
            child: Container(
              margin: EdgeInsets.only(top: 16 + (16 * percent)),
              child: StreamBuilder<String>(
                  stream: PullToReachContext.of(context)
                      .focusIndex
                      .map(_stringForIndex),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) return Container();

                    return Card(
                      elevation: 12,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          snapshot.data,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .title
                              .copyWith(color: Colors.black45),
                        ),
                      ),
                    );
                  }),
            ),
          );
        });
  }

  String _stringForIndex(int index) {
    return widget.instructionText[index];
  }
}

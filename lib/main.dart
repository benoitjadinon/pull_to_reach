import 'package:flutter/material.dart';
import 'package:pull_down_to_reach/widgets/pull_to_reach_scope.dart';
import 'package:pull_down_to_reach/widgets/pull_to_reache_child.dart';
import 'package:pull_down_to_reach/widgets/reachable_item.dart';
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
        body: ScrollToIndexConverter(
          items: [
            ReachableItem(text: "Pull to reach", weight: 2),
            ReachableItem(text: "Release for settings"),
            ReachableItem(text: "Release for search"),
            ReachableItem(text: "Release for something else"),
          ],
          child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AppBar(
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
                  );
                }

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

class ReachableIcon extends StatefulWidget {
  final Widget child;
  final int index;
  final double size;
  final VoidCallback onSelect;
  final Duration duration;

  ReachableIcon(
      {@required this.child,
      @required this.index,
      this.size = 24,
      @required this.onSelect,
      this.duration = const Duration(milliseconds: 100)});

  @override
  _ReachableIconState createState() => _ReachableIconState();
}

class _ReachableIconState extends State<ReachableIcon>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _iconScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 1, end: 1.2));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PullToReachChild(
      index: widget.index,
      onSelect: widget.onSelect,
      onFocusChanged: (isFocused) {
        if (isFocused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return IconButton(
            icon: widget.child,
            onPressed: widget.onSelect,
            iconSize: _iconScaleAnimation.value * widget.size,
          );
        },
        child: Container(),
      ),
    );
  }
}

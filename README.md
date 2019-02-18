# Pull-To-Reach

Pull to reach is utilizing the pull gesture to overcome the problem of accessing the non-reachable controls of an app by highlighting them and triggering them once you release your thumb!



## Usage

```dart
PullToReachContext(
        child: Scaffold(
      appBar: AppBar(
        actions: [
          ReachableIcon(
            icon: Icon(Icons.search),
            index: 1,
            onSelect: _showSearchBox,
          ),
          Reachable(
            index: 2,
            child: someChild,
            onFocusChanged: (isFocused) {
              // customize appearance if focus changes
            },
            onSelect: () {
              // do navigation or trigger action
            },
          ),
        ],
      ),
      body: ScrollToIndexConverter(
        child: _buildList(),
      ),
    ));
```



### Haptic Feedback

Feedback can be configured using `HapticReachableFeedback`

```
// Optionally, vibration can be triggerd for specific indices.
final ReachableFeedback feedback = HapticReachableFeedback(
      shouldVibrateOnFocus: (index) => index > 0,
      shouldVibrateOnSelect: (index) => index > 0);
      
      
      PullToReachContext(
        onFocusChanged: feedback.onFocus,
        onSelectChanged: feedback.onSelect,
        child: yourChild,
     );

```






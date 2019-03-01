import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(NumberManagerWidget(updateMs: 1000, child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inherited Model Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class NumberManagerWidget extends StatefulWidget {
  final int updateMs;
  final Widget child;

  NumberManagerWidget({Key key, @required this.child, @required this.updateMs})
      : assert(updateMs > 0),
        assert(child != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => NumberManagerWidgetState();
}

class NumberManagerWidgetState extends State<NumberManagerWidget> {
  Timer updateTimer;
  int firstTick, secondTick, thirdTick;

  @override
  void initState() {
    super.initState();
    firstTick = secondTick = thirdTick = 0;
    resetTimer();
  }

  @override
  void didUpdateWidget(NumberManagerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    resetTimer();
  }

  void resetTimer() {
    updateTimer?.cancel();
    updateTimer = Timer.periodic(
      Duration(milliseconds: widget.updateMs),
      (Timer t) {
        setState(() {
          firstTick++;
          if (firstTick % 2 == 0) {
            secondTick++;
            if (secondTick % 2 == 0) {
              thirdTick++;
            }
          }
        });
      },
    );
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NumberModel(
      firstValue: firstTick,
      secondValue: secondTick,
      thirdValue: thirdTick,
      child: widget.child,
    );
  }
}

enum NUMBER_TYPE {
  FIRST,
  SECOND,
  THIRD,
}

class NumberModel extends InheritedModel<NUMBER_TYPE> {
  final int firstValue, secondValue, thirdValue;

  NumberModel({
    @required this.firstValue,
    @required this.secondValue,
    @required this.thirdValue,
    @required Widget child,
  }) : super(child: child);

  static NumberModel of(BuildContext context, {NUMBER_TYPE aspect}) {
    return InheritedModel.inheritFrom<NumberModel>(context, aspect: aspect);
  }

  Widget getLabeledText(NUMBER_TYPE type) {
    switch (type) {
      case NUMBER_TYPE.FIRST:
        return Text('First Number: $firstValue');
      case NUMBER_TYPE.SECOND:
        return Text('Second Number: $secondValue');
      case NUMBER_TYPE.THIRD:
        return Text('Third Number: $thirdValue');
    }
    return Text('Unknown Number Type $type');
  }

  @override
  bool updateShouldNotify(NumberModel old) {
    return firstValue != old.firstValue ||
        secondValue != old.secondValue ||
        thirdValue != old.thirdValue;
  }

  @override
  bool updateShouldNotifyDependent(NumberModel old, Set<NUMBER_TYPE> aspects) {
    return (aspects.contains(NUMBER_TYPE.FIRST) &&
            old.firstValue != firstValue) ||
        (aspects.contains(NUMBER_TYPE.SECOND) &&
            old.secondValue != secondValue) ||
        (aspects.contains(NUMBER_TYPE.THIRD) && old.thirdValue != thirdValue);
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inherited Model vs Inherited Widget'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Inherited Model Views'),
                InheritedModelView(type: NUMBER_TYPE.FIRST),
                InheritedModelView(type: NUMBER_TYPE.SECOND),
                InheritedModelView(type: NUMBER_TYPE.THIRD),
                SizedBox(height: 25.0),
                Text('Inherited Widget Views'),
                InheritedWidgetView(type: NUMBER_TYPE.FIRST),
                InheritedWidgetView(type: NUMBER_TYPE.SECOND),
                InheritedWidgetView(type: NUMBER_TYPE.THIRD),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorRegistry {
  final List<Color> colors = [
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  int _idx = 0;

  Color nextColor() {
    if (_idx >= colors.length) {
      _idx = 0;
    }
    return colors[_idx++];
  }
}

class _ColoredBox extends StatelessWidget {
  final Color color;
  final Widget child;

  const _ColoredBox({Key key, this.color, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: EdgeInsets.all(20),
      child: child,
    );
  }
}

class InheritedModelView extends StatelessWidget {
  final _ColorRegistry r = _ColorRegistry();

  final NUMBER_TYPE type;

  InheritedModelView({Key key, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberModel model = NumberModel.of(context, aspect: type);

    return _ColoredBox(
      color: r.nextColor(),
      child: model.getLabeledText(type),
    );
  }
}

class InheritedWidgetView extends StatelessWidget {
  final _ColorRegistry r = _ColorRegistry();

  final NUMBER_TYPE type;

  InheritedWidgetView({Key key, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberModel view = NumberModel.of(context);

    return _ColoredBox(
      color: r.nextColor(),
      child: view.getLabeledText(type),
    );
  }
}

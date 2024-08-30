import 'dart:async';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    trayManager.setIcon('images/tray_icon.png');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green),
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Hack Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _secondsRemaining = 0;
  final int _hackTime = 60 * 60;
  int _startValue = 0;
  int _startTimestamp = 0;
  late NotificationsClient _client;
  Timer? timer;

  _startCounter() async {
    if (null != timer) {
      // Timer is running.
      return;
    }

    await trayManager.setIcon('images/tray_icon_blue.png');
    _startTimestamp = DateTime.now().millisecondsSinceEpoch;
    _startValue = _hackTime;
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _checkTimer(),
    );

    setState(() {
      _counter++;
      _secondsRemaining = _hackTime;
    });
  }

  _setup() async {
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  _checkTimer() async {
    var secsRemaining = _startValue -
        ((DateTime.now().millisecondsSinceEpoch - _startTimestamp) / 1000)
            .floor();
    if (secsRemaining <= 0) {
      await trayManager.setIcon('images/tray_icon_red.png');
      await _client.notify('HACK!', expireTimeoutMs: 0);
      timer!.cancel();
      timer = null;
    }
    setState(() {
      _secondsRemaining = secsRemaining;
    });
  }

  @override
  void initState() {
    _client = NotificationsClient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setup();

    int minutes = (_secondsRemaining / 60).floor();
    int seconds = _secondsRemaining - minutes * 60;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              if (_startValue >= 70) {
                setState(() {
                  _startValue -= 60;
                  _checkTimer();
                });
              }
            },
            icon: const Icon(Icons.exposure_minus_1),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _startValue += 60;
                _checkTimer();
              });
            },
            icon: const Icon(Icons.plus_one),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Hacks today:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              '$minutes:${seconds <= 9 ? 0 : ''}$seconds',
              style: const TextStyle(fontSize: 46),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startCounter,
        tooltip: 'Start Timer',
        child: const Icon(Icons.access_time_filled),
      ),
    );
  }
}

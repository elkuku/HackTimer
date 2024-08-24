import 'dart:async';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';

void main() {
  runApp(const MyApp());
}

/*
import 'dart:async';

import 'package:desktop_notifications/desktop_notifications.dart';

void main() async {
  var client = NotificationsClient();
  Timer.periodic(Duration(seconds:1), (Timer t)=>_getCurrentTime());
  await client.notify('Hello World!');
  //await client.close();
}

 */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    trayManager.setIcon('images/tray_icon.png');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
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
  bool _isRunning = false;
  int _secondsRemaining = 0;
  late NotificationsClient _client;

  _incrementCounter() async {
    await trayManager.setIcon('images/tray_icon_blue.png');

    setState(() {
      _counter++;
      _secondsRemaining = 1 * 60;
      _isRunning = true;
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
    if (false == _isRunning) {
      return;
    }
    if (0 == _secondsRemaining) {
      await trayManager.setIcon('images/tray_icon_red.png');
      await _client.notify('HACK!', expireTimeoutMs: 0);
      _isRunning = false;
      return;
    }
    setState(() {
      _secondsRemaining--;
    });
  }

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _checkTimer());
    _client = NotificationsClient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setup();

    int mins = (_secondsRemaining / 60).floor();
    int secs = _secondsRemaining - mins * 60;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '$mins:$secs',
              style: const TextStyle(fontSize: 46),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

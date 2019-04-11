import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  print('main called');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const MethodChannel channel = MethodChannel('com.app/foreground_channel');
  static const MethodChannel background = MethodChannel('com.app/background_channel');

  @override
  void initState() {
    super.initState();
    final int handle = PluginUtilities.getCallbackHandle(onBackground).toRawHandle();
    channel.invokeMethod('ForegroundRunner.initialize', handle);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Test'),
        ),
      ),
    );
  }
}

void onBackground() {
  const MethodChannel background = MethodChannel('com.app/background_channel');
  background.setMethodCallHandler(doWorkOnBackground);
  background.invokeMethod('BackgroundRunner.initialized');
}

Future<void> doWorkOnBackground(MethodCall call) async {
  print('do job on background');
  return 'result';
}

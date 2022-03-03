import 'dart:async';
import 'dart:io';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io' show Platform;
//import 'package:flutter_email_sender/flutter_email_sender.dart';

void main() {
  runApp(MyApp());
}

const simplePeriodicTask = "simplePeriodicTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("bye");
    print(task);
    switch (task) {
      case simplePeriodicTask:
        print("task entered");
        getUsageStats();

        break;
    }
    return Future.value(true);
  });
}

void getUsageStats() async {
  print("call entered");
  try {
    DateTime endDate = new DateTime.now();
    DateTime startDate = endDate.subtract(Duration(hours: 2));
    List<AppUsageInfo> infoList =
        await AppUsage.getAppUsage(startDate, endDate);

    for (var info in infoList) {
      print(info.toString());
    }
  } on AppUsageException catch (exception) {
    print(exception);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum _Platform { android, ios }

class PlatformEnabledButton extends ElevatedButton {
  final _Platform platform;

  PlatformEnabledButton({
    required this.platform,
    required Widget child,
    required VoidCallback onPressed,
  }) : super(
            child: child,
            onPressed: (Platform.isAndroid && platform == _Platform.android ||
                    Platform.isIOS && platform == _Platform.ios)
                ? onPressed
                : null);
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Plugin initialization",
              ),
              ElevatedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () {
                    print("background services started");
                    Workmanager().initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  }),
              SizedBox(height: 16),
              Text(
                "One Off Tasks (Android only)",
              ),
              //This task runs once.
              //Most likely this will trigger immediately
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("take Location"),
                onPressed: () {
                  Workmanager().registerPeriodicTask("10", simplePeriodicTask,
                      frequency: Duration(minutes: 15),
                      constraints: Constraints(
                        networkType: NetworkType.connected,
                      ));
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("take screen time"),
                onPressed: () {
                  getUsageStats();
                },
              ),

              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Cancel All"),
                onPressed: () async {
                  await Workmanager().cancelAll();
                  print('Cancel all tasks completed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

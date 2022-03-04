import 'dart:async';
import 'dart:io';

//import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:mini_project/app_usage.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io' show Platform;
//import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() {
  runApp(MyApp());
}

const simplePeriodicTask = "simplePeriodicTask";

void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    print("bye");
    print(task);
    switch (task) {
      case simplePeriodicTask:
        print("task entered");
        await getUsageStats();

        break;
    }
    return Future.value(true);
  });
}

dynamic getUsageStats() async {
  print("call entered");
  try {
    DateTime endDate = new DateTime.now();
    DateTime startDate = endDate.subtract(Duration(hours: 2));
    List<AppUsageInfo> infoList =
        await AppUsage.getAppUsage(startDate, endDate);

    for (var info in infoList) {
      print(info.toString());
    }

    // for (int step = 0; step < infoList.length; ++step) {
    //   for (int i = 0; i < infoList.length - step - 1; ++i) {
    //     if (infoList[i].usage > infoList[i + 1].usage) {
    //       dynamic temp = infoList[i].usage;
    //       infoList[i] = infoList[i + 1];
    //       infoList[i + 1] = temp;
    //     }
    //   }
    // }
    // print("after sort....................................");
    // for (var info in infoList) {
    //   print(info.toString());
    // }
    String username = 'mahe.1817130@gct.ac.in';
    String password = 'gct@1234';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'ScreenTime')
      ..recipients.add('mpmahesh1022@gmail.com')
      ..subject = 'ScreenTime:\n  '
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Test</h1>\n<p>${infoList[10]}<br><br><br><br>${infoList[3]}<br><br><br><br>${infoList[7]}<br><br><br><br>${infoList[12]}</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }

    var connection = PersistentConnection(smtpServer);

    // Send the first message
    await connection.send(message);

    // close the connection
    await connection.close();
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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

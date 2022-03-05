import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mini_project/app_usage.dart';
import 'package:mini_project/home.dart';

import 'package:workmanager/workmanager.dart';

import 'package:mailer/mailer.dart';

import 'package:mailer/smtp_server.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
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
    final prefs = await SharedPreferences.getInstance();
    final String? to = prefs.getString('to');

    final String? time = prefs.getString('time');

    int t = int.parse(time.toString());
    DateTime endDate = new DateTime.now();
    DateTime startDate = endDate.subtract(Duration(hours: t));
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

    print("Time:");
    print(time);
    print("\nemail:");
    print(to);

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'ScreenTime')
      ..recipients.add(to)
      ..subject = 'ScreenTime:\n  '
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>Test</h1>\n<p>${infoList[10]}<br><br><br><br>${infoList[3]}<br><br><br><br>${infoList[7]}<br><br><br><br>${infoList[1]}<br><br><br><br>${infoList[2]}<br><br><br><br>${infoList[4]}<br><br><br><br>${infoList[5]}<br><br><br><br>${infoList[6]}<br><br><br><br>${infoList[8]}<br><br><br><br>${infoList[9]}<br><br><br><br>${infoList[11]}<br><br><br><br>${infoList[12]}</p>";

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

void stopMail() async {
  final prefs = await SharedPreferences.getInstance();
  final String? to = prefs.getString('to');

  await Workmanager().cancelAll();
  print('Cancel all tasks completed');

  String username = 'mahe.1817130@gct.ac.in';
  String password = 'gct@1234';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'ScreenTime')
    ..recipients.add(to)
    ..subject = 'ScreenTime:\n  '
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<h1>Screen Monitoring Stopped</h1>";

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

  await connection.send(message);

  await connection.close();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

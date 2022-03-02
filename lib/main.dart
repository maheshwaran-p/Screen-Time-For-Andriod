import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io' show Platform;

import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

void main() {
  runApp(MyApp());
}

const simpleTaskKey = "simpleTask";
//const starttele = "simplePeriodicTask";

const simplePeriodicTask = "simplePeriodicTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simplePeriodicTask was executed2222");
        var bOTTOKEN = '5038745862:AAFWBn8quZcLeGbgrxAo0eKvTgkS6KLz3a8';
        print('hiii');
        final username = (await Telegram(bOTTOKEN).getMe()).username;
        print('bye....');
        var teledart = TeleDart(bOTTOKEN, Event(username!));

        teledart.start();
        print('kabiiiii');

        teledart.onMessage(keyword: 'start').listen((message) {
          print(message);
          message.reply('Stand with Hong Kong');
        });
        print('maheeeeee');

        teledart
            .onMessage(entityType: 'bot_command', keyword: 'check')
            .listen((message) async {
          print('entereeen');
          teledart.getChat(message.chat.id);
          await teledart.sendMessage(message.chat.id,
              'Great News BackGround Services Started Successfully!');
        });
        print('okkkkk');
        break;

      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        var bOTTOKEN = '5038745862:AAFWBn8quZcLeGbgrxAo0eKvTgkS6KLz3a8';
        print('hiii');
        final username = (await Telegram(bOTTOKEN).getMe()).username;
        print('bye....');
        var teledart = TeleDart(bOTTOKEN, Event(username!));

        teledart.start();
        print('kabiiiii');

        teledart.onMessage(keyword: 'start').listen((message) {
          // print(message);
          message.reply('Stand with Hong Kong');
        });
        print('maheeeeee');

        teledart
            .onCommand('start')
            .listen((message) => message.reply('This works too!'));
        print('okkkkk');
        break;
    }

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
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
              FlatButton(
                //  platform: _Platform.android,
                child: Text("take Location"),
                onPressed: () {
                  Workmanager().registerPeriodicTask("10", simplePeriodicTask,
                      frequency: Duration(minutes: 15),
                      constraints: Constraints(
                        networkType: NetworkType.connected,
                      ));
                },
              ),

              FlatButton(
                // platform: _Platform.android,
                child: Text("Start the Bot"),
                onPressed: () async {
                  Workmanager().registerOneOffTask("1", "simpleTask",
                      constraints: Constraints(
                          networkType: NetworkType.connected,
                          requiresBatteryNotLow: true,
                          requiresCharging: true,
                          requiresDeviceIdle: true,
                          requiresStorageNotLow: true));
                },
              ),

              FlatButton(
                // platform: _Platform.android,
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

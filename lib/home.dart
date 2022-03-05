import 'package:flutter/material.dart';
import 'package:mini_project/main.dart';
import 'package:mini_project/screen_time.dart';

import 'package:workmanager/workmanager.dart';

import 'package:another_flushbar/flushbar.dart';

import 'package:system_settings/system_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
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

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    TextEditingController emailController = new TextEditingController();
    TextEditingController timeintervalController = new TextEditingController();
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Parental Control"),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: GestureDetector(
                            onTap: () {
                              stopMail();
                            },
                            child: Text("Stop Receiving Mail")),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Screentime()),
                              );
                            },
                            child: Text("My Screen Time")),
                        value: 2,
                      )
                    ])
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                      "Step 1 : Enter Email to send the Screen time Report "),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: new InputDecoration(
                    labelText: "Enter Email",
                    hintText: "Enter Your Email",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    String pattern =
                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?)*$";
                    RegExp regex = RegExp(pattern);
                    if (val == null || val.isEmpty || !regex.hasMatch(val))
                      return 'Enter a valid email address';
                    else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  style: new TextStyle(
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 16),
                Text(
                    "Step 2 : Set time Interval in Hours and Submit the Details "),
                SizedBox(height: 16),
                TextFormField(
                  controller: timeintervalController,
                  decoration: new InputDecoration(
                    labelText: "Time Interval",
                    hintText: "Enter Number",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {},
                  keyboardType: TextInputType.emailAddress,
                  style: new TextStyle(
                    fontFamily: "Poppins",
                  ),
                ),
                SizedBox(height: 16),
                PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Submit Details "),
                  onPressed: () async {
                    if (emailController.text.length != 0 &&
                        timeintervalController.text.length != 0) {
                      Flushbar(
                        message: "Submitted Successfully",
                        icon: Icon(
                          Icons.info_outline,
                          size: 28.0,
                          color: Colors.blue[300],
                        ),
                        duration: Duration(seconds: 5),
                        leftBarIndicatorColor: Colors.blue[300],
                      )..show(context);
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setString('to', emailController.text);
                      await prefs.setString(
                          'time', timeintervalController.text);
                    } else {
                      Flushbar(
                        message: "Email or Time Interval Shouldn't be Empty.",
                        icon: Icon(
                          Icons.info_outline,
                          size: 28.0,
                          color: Colors.blue[300],
                        ),
                        duration: Duration(seconds: 5),
                        leftBarIndicatorColor: Colors.blue[300],
                      )..show(context);
                    }
                  },
                ),

                SizedBox(height: 16),

                Text(
                    "Step 3: Enable AutoStart Permission to send Report through mail even if the app is in background "),
                SizedBox(height: 16),

                PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("AutoStart Permission "),
                  onPressed: SystemSettings.app,
                ),

                SizedBox(height: 16),
                Text("Step 4: intiatilize the App "),
                SizedBox(height: 16),
                PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Initialize the App "),
                  onPressed: () {
                    print("background services started");
                    Workmanager().initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  },
                ),
                SizedBox(height: 16),
                //This task runs once.
                //Most likely this will trigger immediately
                Text(
                    "Step 5: Give Permission to this app to take screen time "),
                SizedBox(height: 16),
                PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Screen Time Permission "),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final String? time = prefs.getString('time');
                    print("Time Interval");
                    print(time.toString());

                    if (time.toString() != "null") {
                      getUsageStats();
                    } else {
                      Flushbar(
                        message: "please Enter Time Interval to Start",
                        icon: Icon(
                          Icons.info_outline,
                          size: 28.0,
                          color: Colors.blue[300],
                        ),
                        duration: Duration(seconds: 5),
                        leftBarIndicatorColor: Colors.blue[300],
                      )..show(context);
                    }
                  },
                ),
                SizedBox(height: 16),

                Text(
                    "Step 6: Start receiving screen time  Report of this Device "),
                SizedBox(height: 16),

                PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Start"),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final String? to = prefs.getString('to');

                    final String? time = prefs.getString('time');

                    print("mail and time");
                    print(to.toString().length);
                    print(time.toString());
                    if (to.toString().length > 4 && time.toString() != "null") {
                      Flushbar(
                        message:
                            "Started Successfully . We will Send the Screen Time Report of this Device for every ${time.toString()} hours ",
                        icon: Icon(
                          Icons.info_outline,
                          size: 28.0,
                          color: Colors.blue[300],
                        ),
                        duration: Duration(seconds: 5),
                        leftBarIndicatorColor: Colors.blue[300],
                      )..show(context);

                      int t = int.parse(time.toString());
                      Workmanager()
                          .registerPeriodicTask("10", simplePeriodicTask,
                              frequency: Duration(hours: t),
                              constraints: Constraints(
                                networkType: NetworkType.connected,
                              ));
                    } else {
                      print(to.toString());
                      print(time.toString());
                      Flushbar(
                        message: "Email or Time interval Shouldn't be Empty",
                        icon: Icon(
                          Icons.info_outline,
                          size: 28.0,
                          color: Colors.blue[300],
                        ),
                        duration: Duration(seconds: 5),
                        leftBarIndicatorColor: Colors.blue[300],
                      )..show(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

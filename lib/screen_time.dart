import 'package:flutter/material.dart';

import 'app_usage.dart';

class Screentime extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Screentime> {
  List<AppUsageInfo> _infos = [];

  @override
  void initState() {
    getUsageStats();
    super.initState();
  }

  void getUsageStats() async {
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 2));
      List<AppUsageInfo> infoList =
          await AppUsage.getAppUsage(startDate, endDate);
      setState(() {
        _infos = infoList;
      });

      for (var info in infoList) {
        print(info.toString());
      }
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text('My Screen Time'),
          backgroundColor: Colors.green,
        ),
        body: ListView.builder(
            itemCount: _infos.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(_infos[index].appName),
                  trailing: Text(_infos[index].usage.toString()));
            }),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import 'package:http/http.dart' as http;

import '../api/auth.dart' as auth;
import '../api/notificationController.dart' as notificationController;
import '../api/timeController.dart' as timeController;

class Pictures extends StatefulWidget {
  Pictures({Key key}) : super(key: key);

  @override
  PicturesState createState() => PicturesState();
}

class PicturesState extends State<Pictures> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer clockTimerNotification;

  List<dynamic> pictures = [];

  Future<dynamic> getBackendPictures() async {
    String url = auth.getIpAddress()+"/pictures?_sort=sort:asc";
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ('Failed to load post');
    }
  }

  getPictures() async {
    List<dynamic> response;
    try {
      response = await getBackendPictures();
      setState(() {
        pictures = response;
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = notificationController
        .initializeNotification(flutterLocalNotificationsPlugin);
    clockTimerNotification =
        Timer.periodic(new Duration(minutes: 1), (timer) async {
      if (timeController.isDateNowEvery30Minutes()) {
        await notificationController
            .showNotification(flutterLocalNotificationsPlugin);
      }
    });
    getPictures();
  }

  @override
  void dispose() {
    clockTimerNotification.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('IMÁGENES'),
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
                padding: EdgeInsets.all(10.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.cyan[800],
                    width: 1,
                  ),
                ),
                child: Text(
                  pictures.length == 1
                      ? 'Se encontró ${pictures.length} imagen'
                      : 'Se encontraron ${pictures.length} imágenes',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              Container(
                child: Expanded(
                  child: ListView.builder(
                    itemCount: pictures.length,
                    itemBuilder: (context, index) {
                      return Container(
                          margin: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
                          padding: EdgeInsets.all(5.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.cyan[800],
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: 200),
                                    child: Image.network(
                                      auth.getIpAddress() +
                                          pictures[index]['image']['url'],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5.0),
                                    color: Colors.grey.withOpacity(0.1),
                                    child: Text(pictures[index]['description'],
                                        textAlign: TextAlign.justify,
                                        style: new TextStyle(fontSize: 14)),
                                  )
                                ],
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.cyan[800],
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(pictures[index]['title'],
                                      style: new TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.75),
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ));
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomBar.bottomNavigationBar(context));
  }
}

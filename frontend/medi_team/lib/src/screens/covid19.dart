import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import 'package:url_launcher/url_launcher.dart';

import '../api/notificationController.dart' as notificationController;
import '../api/timeController.dart' as timeController;

class Covid19 extends StatefulWidget {
  Covid19({Key key}) : super(key: key);

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<Covid19> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer clockTimerNotification;

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
  }

  @override
  void dispose() {
    clockTimerNotification.cancel();
    super.dispose();
  }

  void logout() async {
    const url =
        'https://www.who.int/es/emergencies/diseases/novel-coronavirus-2019/advice-for-public/q-a-coronaviruses';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget logo() {
      return Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: Image(
            image: AssetImage('assets/images/covid19.png'),
            height: MediaQuery.of(context).size.width * 1.4,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('COVID-19', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.cyan.withOpacity(0.1),
          ),
          Container(
            child: Center(
              child: logo(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar.bottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: logout,
        tooltip: 'Cerrar Sesión',
        child: FaIcon(
          FontAwesomeIcons.question,
          color: Colors.white,
        ),
      ),
    );
  }
}

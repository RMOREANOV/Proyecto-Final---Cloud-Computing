import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medi_team/src/screens/bookMedicalConsultation.dart';
import 'package:medi_team/src/screens/editPatient.dart';
import 'package:medi_team/src/screens/homePageWithoutAuth.dart';

import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import '../api/sharedPreferences.dart' as sharedPreferences;
import 'package:medi_team/src/api/navigatorPush.dart' as NavigatorPush;

import '../api/auth.dart' as auth;
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/notificationController.dart' as notificationController;
import '../api/timeController.dart' as timeController;

class HomePageWithAuth extends StatefulWidget {
  HomePageWithAuth({Key key}) : super(key: key);

  @override
  HomePageWithAuthState createState() => HomePageWithAuthState();
}

class HomePageWithAuthState extends State<HomePageWithAuth> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<dynamic> medicalConsultations = [];
  int countMedicalConsultations = 0;
  Timer clockTimerGetMedicalConsultations;
  Timer clockTimerNotification;
  var patient;
  void logout() async {
    await sharedPreferences.clearAppStorage();
    NavigatorPush.navigatorPushReplacement(context, HomePageWithoutAuth());
  }

  Future<dynamic> getBackendDoctor() async {
    String token = await auth.getToken();
    String patientId = await auth.getPatientId();
    String url = "http://10.0.2.2:1337/patients/$patientId";
    http.Response response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ('Failed to load post');
    }
  }

  getDoctor() async {
    dynamic response;
    try {
      response = await getBackendDoctor();
      setState(() {
        patient = response;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<dynamic> getBackendMedicalConsultations() async {
    String token = await auth.getToken();
    var patientId = patient['id'];
    String url =
        "http://10.0.2.2:1337/medical-consultations?patient=$patientId&_sort=datetime:asc";
    http.Response response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ('Failed to load post');
    }
  }

  getMedicalConsultations() async {
    List<dynamic> response;
    try {
      response = await getBackendMedicalConsultations();
      var medicalConsultationClose =
          await timeController.getMedicalConsultationClose();
      setState(() {
        medicalConsultations = response;
        countMedicalConsultations = medicalConsultations.length;
        for (var i = 0; i < medicalConsultations.length; i++) {
          if (timeController.isMedicalConsultationClose(
                  DateTime.parse(medicalConsultations[i]['datetime'])
                      .toLocal()) &&
              medicalConsultations[i]['isVisible'] == true) {
            timeController.setMedicalConsultationClose(
                medicalConsultations[i]['datetime']);

            break;
          }
        }
      });
      if (medicalConsultationClose == null) {
        await notificationController
            .showNotification(flutterLocalNotificationsPlugin);
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = notificationController
        .initializeNotification(flutterLocalNotificationsPlugin);

    () async {
      await getDoctor();
      await getMedicalConsultations();
    }();
    clockTimerGetMedicalConsultations =
        Timer.periodic(new Duration(seconds: 15), (timer) async {
      await getMedicalConsultations();
    });

    clockTimerNotification =
        Timer.periodic(new Duration(minutes: 30), (timer) async {
      if (timeController.isDateNowEvery30Minutes()) {
        await notificationController
            .showNotification(flutterLocalNotificationsPlugin);
      }
    });
  }

  @override
  void dispose() {
    clockTimerGetMedicalConsultations.cancel();
    clockTimerNotification.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('INICIO'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
                padding: EdgeInsets.all(5.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.cyan[800],
                    width: 1,
                  ),
                ),
                child: Stack(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.cyan[800].withOpacity(0.2))),
                            child: SizedBox(
                                width: 80,
                                height: 80,
                                child: (patient == null ||
                                        patient['photo'] == null)
                                    ? Image(
                                        image: AssetImage(
                                            'assets/images/patient.jpg'),
                                        height: 80,
                                        width: 80,
                                      )
                                    : Image.network(
                                        "http://10.0.2.2:1337" +
                                            patient['photo']['url'],
                                      )),
                          )),
                      Flexible(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(
                                  top: 8, right: 2, bottom: 7.5),
                              child: Text(
                                  patient != null
                                      ? patient['firstname'] +
                                          " " +
                                          patient['lastname']
                                      : "",
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.75)))),
                          Text(patient != null ? patient['user']['email'] : "",
                              style: new TextStyle(
                                  color: Colors.black.withOpacity(0.75))),
                          Container(
                            padding: EdgeInsets.only(
                                top: 7.5, right: 2, bottom: 7.5),
                            child: Text(
                                patient != null
                                    ? (patient['phone'] != ""
                                        ? "Telf.: " + patient['phone']
                                        : patient['phone'])
                                    : "",
                                style: new TextStyle(
                                    color: Colors.black.withOpacity(0.8))),
                          ),
                        ],
                      )),
                    ],
                  ),
                  Positioned(
                      top: 1,
                      right: 1,
                      child: Material(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.cyan[800].withOpacity(0.075),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            radius: 25,
                            onTap: () async {
                              NavigatorPush.navigatorPushReplacement(
                                  context, EditPatient(patient: patient));
                            },
                            splashColor: Colors.cyan[800].withOpacity(0.1),
                            highlightColor: Colors.cyan[800].withOpacity(0.1),
                            child: Container(
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.edit,
                                size: 15,
                                color: Colors.cyan[800].withOpacity(0.75),
                              ),
                            ),
                          ))),
                  patient != null
                      ? Positioned(
                          bottom: 1,
                          right: 10,
                          child: FaIcon(
                            patient['gender']['name'] == "Male"
                                ? FontAwesomeIcons.male
                                : FontAwesomeIcons.female,
                            color: Colors.cyan[700],
                          ))
                      : Container()
                ])),
            Container(
              margin: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
              width: double.infinity,
              child: FlatButton(
                  color: Colors.yellow.withOpacity(0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Colors.yellow[800],
                      )),
                  textColor: Colors.yellow[800],
                  onPressed: () async {
                    NavigatorPush.navigatorPushReplacement(context,
                        BookMedicalConsultation(patientId: patient['id']));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: new TextSpan(
                          style: new TextStyle(fontSize: 14.0),
                          children: <TextSpan>[
                            new TextSpan(
                                text: "¡OFERTA! ",
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                            new TextSpan(
                                text: "S/.59 ",
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlue)),
                            new TextSpan(
                                text: 'CONSULTA MÉDICA ',
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.6)))
                          ],
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.mousePointer,
                        color: Colors.black.withOpacity(0.15),
                        size: 18,
                      )
                    ],
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.2),
                border: Border.all(
                  color: Colors.cyan[800],
                  width: 1,
                ),
              ),
              child: Text(
                countMedicalConsultations == 1
                    ? 'Tienes $countMedicalConsultations consulta médica.'
                    : 'Tienes $countMedicalConsultations consultas médicas.',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            countMedicalConsultations != 0
                ? Container()
                : Container(
                    margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                    height: 180,
                    child: Opacity(
                      opacity: 0.75,
                      child: Image(
                          image:
                              AssetImage('assets/images/homepage_message.png'),
                          width: double.infinity),
                    ),
                  ),
            Container(
              child: Expanded(
                child: ListView.builder(
                  itemCount: medicalConsultations.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 10.0),
                        padding: EdgeInsets.all(5.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: medicalConsultations[index]['isVisible'] ==
                                  true
                              ? (timeController.isMedicalConsultationNow(
                                      DateTime.parse(medicalConsultations[index]
                                              ['datetime'])
                                          .toLocal())
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2))
                              : Colors.red.withOpacity(0.2),
                          border: Border.all(
                            color: medicalConsultations[index]['isVisible'] ==
                                    true
                                ? (timeController.isMedicalConsultationNow(
                                        DateTime.parse(
                                                medicalConsultations[index]
                                                    ['datetime'])
                                            .toLocal())
                                    ? Colors.orange[400]
                                    : Colors.green[800])
                                : Colors.red[400],
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.05))),
                                          child: SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/images/clock.jpg'),
                                              )),
                                        )),
                                    Container(
                                        height: 60,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                timeController.dateTimeToTitle(
                                                    DateTime.parse(
                                                            medicalConsultations[
                                                                    index]
                                                                ['datetime'])
                                                        .toLocal()),
                                                style: new TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 5, right: 2),
                                              child: Text(
                                                  timeController.datetimeToSubtitle(
                                                      DateTime.parse(
                                                              medicalConsultations[
                                                                      index]
                                                                  ['datetime'])
                                                          .toLocal()),
                                                  textAlign: TextAlign.justify,
                                                  style: new TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6))),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.05))),
                                          child: SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Image.network(
                                                  "http://10.0.2.2:1337" +
                                                      medicalConsultations[
                                                              index]['doctor']
                                                          ['photo']['url'])),
                                        )),
                                    Container(
                                        height: 60,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                "Dr. " +
                                                    medicalConsultations[index]
                                                            ['doctor']
                                                        ['firstname'] +
                                                    " " +
                                                    medicalConsultations[index]
                                                        ['doctor']['lastname'],
                                                style: new TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 5, right: 2),
                                              child: Text(
                                                  medicalConsultations[index]
                                                          ['doctor']
                                                      ['specialty']['name'],
                                                  textAlign: TextAlign.justify,
                                                  style: new TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6))),
                                            )
                                          ],
                                        )),
                                  ],
                                )
                              ],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: medicalConsultations[index]
                                                ['isVisible'] ==
                                            true
                                        ? (timeController
                                                .isMedicalConsultationNow(
                                                    DateTime.parse(
                                                            medicalConsultations[
                                                                    index]
                                                                ['datetime'])
                                                        .toLocal())
                                            ? Colors.orange[400]
                                            : Colors.green[800])
                                        : Colors.red[400],
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  medicalConsultations[index]['isVisible'] ==
                                          true
                                      ? (timeController
                                              .isMedicalConsultationNow(
                                                  DateTime.parse(
                                                          medicalConsultations[
                                                                  index]
                                                              ['datetime'])
                                                      .toLocal())
                                          ? "Ahora"
                                          : "Por realizar")
                                      : "Terminado",
                                  style: TextStyle(fontSize: 10.5),
                                ),
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
      bottomNavigationBar: BottomBar.bottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
          onPressed: logout,
          tooltip: 'Cerrar Sesión',
          child: Transform.rotate(
            angle: math.pi,
            child: FaIcon(
              FontAwesomeIcons.signOutAlt,
              color: Colors.white,
            ),
          )),
    );
  }
}

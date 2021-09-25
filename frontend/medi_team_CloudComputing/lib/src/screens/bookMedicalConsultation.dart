import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medi_team/src/screens/homePageWithAuth.dart';
import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import 'package:medi_team/src/api/navigatorPush.dart' as NavigatorPush;

import '../api/auth.dart' as auth;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/email.dart' as email;

import '../api/notificationController.dart' as notificationController;
import '../api/timeController.dart' as timeController;

class BookMedicalConsultation extends StatefulWidget {
  final patientId;
  BookMedicalConsultation({Key key, this.patientId}) : super(key: key);

  @override
  BookallDataMedicalConsultationtate createState() =>
      BookallDataMedicalConsultationtate(patientId);
}

class BookallDataMedicalConsultationtate
    extends State<BookMedicalConsultation> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer clockTimerNotification;

  String token;

  int counter = 90;

  var patientId;
  DateTime dateForm;
  TimeOfDay timeForm;
  List<dynamic> genders = [];
  List<dynamic> specialties = [];
  List<dynamic> doctors = [];
  List<dynamic> medicalConsultations = [];

  final formKey = GlobalKey<FormState>();

  String specialtyDropdownValue;
  String doctorDropdownValue;
  List<dynamic> days = [];
  String daySelected = '';
  List<dynamic> hoursMorning = [];
  List<dynamic> hoursAfternoon = [];
  List<dynamic> hoursEvening = [];
  String medicalConsultationId = '';

  BookallDataMedicalConsultationtate(this.patientId);

  bool formLoginIsVisible = false;
  final formKeyLogin = GlobalKey<FormState>();
  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();

  bool formCreatePatientIsVisible = false;
  final formKeyCreatePatient = GlobalKey<FormState>();
  final emailCreatePatientController = TextEditingController();
  final passwordCreatePatientController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  int genderValue = 0;
  File picture;
  final picker = ImagePicker();
  final phoneController = TextEditingController();

  String timeToString(TimeOfDay timeOfDay) {
    var hour = timeOfDay.hour;
    var minute = timeOfDay.minute;
    return ("0" + hour.toString()).substring(hour.toString().length - 1) +
        ":" +
        ("0" + minute.toString()).substring(minute.toString().length - 1);
  }

  String hourMinuteToString(TimeOfDay timeOfDay) {
    var hour = timeOfDay.hour;
    var minute = timeOfDay.minute;
    var newHour = minute == 30 ? hour + 1 : hour;
    var newMinute = minute == 30 ? 0 : 30;
    return ("0" + hour.toString()).substring(hour.toString().length - 1) +
        ":" +
        ("0" + minute.toString()).substring(minute.toString().length - 1) +
        " - " +
        ("0" + newHour.toString()).substring(newHour.toString().length - 1) +
        ":" +
        ("0" + newMinute.toString()).substring(newMinute.toString().length - 1);
  }

  getAllDataMedicalConsultation() async {
    dynamic response;
    try {
      response = await getBackendAllDataMedicalConsultation();
      setState(() {
        genders = response['genders'];
        specialties = response['specialties'];
        medicalConsultations = response['medicalConsultations'];
      });
    } catch (error) {
      print(error);
    }
  }

  Future<dynamic> getBackendAllDataMedicalConsultation() async {
    var timezoneOffsetMilliseconds =
        new DateTime.now().timeZoneOffset.inMilliseconds;
    String url=auth.getIpAddress()+"/all-data-medical-consultation?timezoneOffsetMilliseconds=$timezoneOffsetMilliseconds";
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ('Failed to load post');
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
    () async {
      token = await auth.getToken();
      await getAllDataMedicalConsultation();
    }();
  }

  @override
  void dispose() {
    clockTimerNotification.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget specialtyInput() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          child: Text(
            "Especialidad",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20),
          child: DropdownButtonFormField(
            hint: Text(
              specialties.length == 0
                  ? "Ninguna especialidad encontrada"
                  : "Seleccione una especialidad",
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            value: specialtyDropdownValue,
            onChanged: (String newValue) {
              setState(() {
                specialtyDropdownValue = newValue;
                doctorDropdownValue = null;
                daySelected = '';
                hoursMorning.clear();
                hoursAfternoon.clear();
                hoursEvening.clear();
                medicalConsultationId = '';
                doctors = specialties.firstWhere((specialty) =>
                    specialty['id'].toString() ==
                    specialtyDropdownValue)['doctors'];
              });
            },
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            validator: (value) {
              if (value == null) {
                return "Seleccione una especialidad de la lista";
              }
              return null;
            },
            items: specialties.map((specialty) {
              return DropdownMenuItem(
                  value: specialty['id'].toString(),
                  child: Text(specialty['name']));
            }).toList(),
          ),
        )
      ]);
    }

    Widget doctorInput() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          child: Text(
            "Doctor",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20),
          child: new DropdownButtonFormField(
            hint: Text(
              doctors.length == 0
                  ? "Ningún doctor encontrado"
                  : "Seleccione un Doctor",
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            value: doctorDropdownValue,
            isDense: doctors.length == 0 ? true : false,
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                doctorDropdownValue = newValue;
                daySelected = '';
                hoursMorning.clear();
                hoursAfternoon.clear();
                hoursEvening.clear();
                medicalConsultationId = '';
                days.clear();
                for (var i = 0; i < medicalConsultations.length; i++) {
                  if (medicalConsultations[i]['doctor']['id'].toString() ==
                      doctorDropdownValue) {
                    if (days.length == 0 ||
                        medicalConsultations[i]['localeDateMiliseconds'] !=
                            medicalConsultations[i - 1]
                                ['localeDateMiliseconds']) {
                      days.add({
                        'localeDateMiliseconds': medicalConsultations[i]
                            ['localeDateMiliseconds'],
                        'localeDayNames': medicalConsultations[i]
                            ['localeDayNames'],
                        'localeDate': medicalConsultations[i]['localeDate'],
                        'localeMonthNames': medicalConsultations[i]
                            ['localeMonthNames'],
                        'localeFullYear': medicalConsultations[i]
                            ['localeFullYear']
                      });
                    }
                  }
                }
              });
            },
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            validator: (value) {
              if (value == null) {
                return "Seleccione un doctor de la lista";
              }
              return null;
            },
            items: doctors.map((doctor) {
              return DropdownMenuItem(
                  value: doctor['id'].toString(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.05))),
                            child: SizedBox(
                                width: 50,
                                height: 50,
                                child: doctor['photo'] == null
                                    ? Image(
                                        image: Image.network('https://medi-team.s3.amazonaws.com/doctor.jpg').image)
                                    : Image.network(auth.getIpAddress() +
                                        doctor['photo']['url'])),
                          )),
                      Container(
                          height: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(doctor['firstname'],
                                  style: new TextStyle(fontSize: 14)),
                              Container(
                                padding: EdgeInsets.only(top: 5, right: 2),
                                child: Text(doctor['lastname'],
                                    textAlign: TextAlign.justify,
                                    style: new TextStyle(
                                        fontSize: 14,
                                        color: Colors.black.withOpacity(0.8))),
                              )
                            ],
                          )),
                    ],
                  ));
            }).toList(),
          ),
        )
      ]);
    }

    Widget dateInput() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          child: Text(
            "Días",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        days.length != 0
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                height: 90.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: days.map((date) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: 40.0,
                      child: FlatButton(
                        padding: EdgeInsets.all(2),
                        color: daySelected ==
                                date['localeDateMiliseconds'].toString()
                            ? Colors.cyan[600]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                                color: Colors.black.withOpacity(0.25))),
                        onPressed: () {
                          daySelected =
                              date['localeDateMiliseconds'].toString();
                          setState(() {
                            hoursMorning.clear();
                            hoursAfternoon.clear();
                            hoursEvening.clear();
                            for (var i = 0;
                                i < medicalConsultations.length;
                                i++) {
                              if (medicalConsultations[i]['doctor']['id']
                                          .toString() ==
                                      doctorDropdownValue &&
                                  medicalConsultations[i]
                                              ['localeDateMiliseconds']
                                          .toString() ==
                                      date['localeDateMiliseconds']
                                          .toString()) {
                                var medicalConsultationData = {
                                  'medicalConsultationId':
                                      medicalConsultations[i]['id'],
                                  'medicalConsultationLocaleTimeString':
                                      medicalConsultations[i]
                                          ['localeTimeString'],
                                  'medicalConsultationLocaleTypeTime':
                                      medicalConsultations[i]['localeTypeTime']
                                };
                                if (medicalConsultations[i]['localeTypeTime'] ==
                                    'morning') {
                                  hoursMorning.add(medicalConsultationData);
                                } else if (medicalConsultations[i]
                                        ['localeTypeTime'] ==
                                    'afternoon') {
                                  hoursAfternoon.add(medicalConsultationData);
                                } else {
                                  hoursEvening.add(medicalConsultationData);
                                }
                              }
                            }
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(date['localeDayNames'].substring(0, 4),
                                style: TextStyle(
                                    color: daySelected ==
                                            date['localeDateMiliseconds']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.6),
                                    fontSize: 14)),
                            Text(date['localeDate'].toString(),
                                style: TextStyle(
                                    color: daySelected ==
                                            date['localeDateMiliseconds']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.65),
                                    fontSize: 23)),
                            Text(date['localeMonthNames'].substring(0, 4),
                                style: TextStyle(
                                    color: daySelected ==
                                            date['localeDateMiliseconds']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.6),
                                    fontSize: 14)),
                            Text(date['localeFullYear'].toString(),
                                style: TextStyle(
                                    color: daySelected ==
                                            date['localeDateMiliseconds']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.5),
                                    fontSize: 12))
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text("Ningún día encontrado",
                      style: TextStyle(
                          fontSize: 16, color: Colors.black.withOpacity(0.6))),
                ),
              ),
      ]);
    }

    Widget timeInput() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
          child: Text(
            "Horas disponibles",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        hoursMorning.length != 0
            ? Container(
                margin: EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  "Mañana",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.75), fontSize: 12),
                ),
              )
            : Container(),
        hoursMorning.length != 0
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                height: 30.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: hoursMorning.map((time) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: 80.0,
                      child: FlatButton(
                        padding: EdgeInsets.all(2),
                        color: medicalConsultationId ==
                                time['medicalConsultationId'].toString()
                            ? Colors.cyan[600]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black.withOpacity(0.25))),
                        onPressed: () {
                          setState(() {
                            medicalConsultationId =
                                time['medicalConsultationId'].toString();
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(time['medicalConsultationLocaleTimeString'],
                                style: TextStyle(
                                    color: medicalConsultationId ==
                                            time['medicalConsultationId']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.6),
                                    fontSize: 14))
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : Container(),
        hoursAfternoon.length != 0
            ? Container(
                margin: EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  "Tarde",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.75), fontSize: 12),
                ),
              )
            : Container(),
        hoursAfternoon.length != 0
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                height: 30.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: hoursAfternoon.map((time) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: 80.0,
                      child: FlatButton(
                        padding: EdgeInsets.all(2),
                        color: medicalConsultationId ==
                                time['medicalConsultationId'].toString()
                            ? Colors.cyan[600]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black.withOpacity(0.25))),
                        onPressed: () {
                          setState(() {
                            medicalConsultationId =
                                time['medicalConsultationId'].toString();
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(time['medicalConsultationLocaleTimeString'],
                                style: TextStyle(
                                    color: medicalConsultationId ==
                                            time['medicalConsultationId']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.6),
                                    fontSize: 14))
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : Container(),
        hoursEvening.length != 0
            ? Container(
                margin: EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  "Noche",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.75), fontSize: 12),
                ),
              )
            : Container(),
        hoursEvening.length != 0
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                height: 30.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: hoursEvening.map((time) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: 80.0,
                      child: FlatButton(
                        padding: EdgeInsets.all(2),
                        color: medicalConsultationId ==
                                time['medicalConsultationId'].toString()
                            ? Colors.cyan[600]
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.black.withOpacity(0.25))),
                        onPressed: () {
                          setState(() {
                            medicalConsultationId =
                                time['medicalConsultationId'].toString();
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(time['medicalConsultationLocaleTimeString'],
                                style: TextStyle(
                                    color: medicalConsultationId ==
                                            time['medicalConsultationId']
                                                .toString()
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.6),
                                    fontSize: 14))
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : Container(),
        (hoursMorning.length == 0 &&
                hoursAfternoon.length == 0 &&
                hoursEvening.length == 0)
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text("Ninguna hora disponible",
                      style: TextStyle(
                          fontSize: 16, color: Colors.black.withOpacity(0.6))),
                ),
              )
            : Container(),
      ]);
    }

    formError(context, error) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(error)));
    }

    formSuccess(response) async {
      FocusScope.of(context).unfocus();
      NavigatorPush.navigatorPushReplacement(context, HomePageWithAuth());
    }

    Future<dynamic> getResponseBookMedicalConsultation() async {
      String url = auth.getIpAddress()+"/medical-consultations/$medicalConsultationId";
      http.Response response = await http.put(url,
          headers: {
            "Authorization": 'Bearer $token',
            "Content-Type": "application/json"
          },
          body: jsonEncode(<String, String>{'patient': patientId.toString()}));
      final Map<String, dynamic> responseJson = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseJson;
      } else {
        throw responseJson['message'];
      }
    }

    Widget formButton() {
      return Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: Builder(
              builder: (context) => SizedBox(
                    width: double.infinity,
                    height: 40.0,
                    child: OutlineButton(
                      highlightedBorderColor: Colors.cyan[700],
                      borderSide: BorderSide(color: Colors.black),
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          if (daySelected == "") {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("No se ha seleccionado algún día")));
                          } else if (medicalConsultationId == "") {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("No se ha seleccionado alguna hora")));
                          } else {
                            if (token != null) {
                              Map<String, dynamic> response;
                              try {
                                response =
                                    await getResponseBookMedicalConsultation();
                                formSuccess(response);
                              } catch (error) {
                                formError(context, error);
                              }
                            } else {
                              setState(() {
                                formLoginIsVisible = true;
                              });
                            }
                          }
                        }
                      },
                      child: Text('RESERVAR SOLICITUD',
                          style: TextStyle(color: Colors.black)),
                    ),
                  )));
    }

    Widget titleLogin() {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
          child: Text(
            "Inicia Sesión",
            style: new TextStyle(
                color: Colors.cyan[700],
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    Widget emailInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
        child: new TextFormField(
            controller: emailLoginController,
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            autofocus: false,
            decoration: new InputDecoration(
                hintText: 'Correo Electrónico',
                icon: new Icon(
                  Icons.mail,
                  color: Colors.grey,
                )),
            validator: (value) {
              if (email.isValidEmail(value)) {
                return 'Ingrese un Correo Electrónico válido';
              }
              return null;
            }),
      );
    }

    Widget passwordInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
        child: new TextFormField(
            controller: passwordLoginController,
            maxLines: 1,
            obscureText: true,
            autofocus: false,
            decoration: new InputDecoration(
                hintText: 'Contraseña',
                icon: new Icon(
                  Icons.lock,
                  color: Colors.grey,
                )),
            validator: (value) {
              if (value.isEmpty) {
                return 'Ingrese alguna contraseña';
              }
              return null;
            }),
      );
    }

    Future<dynamic> getResponse() async {
      String url = auth.getIpAddress()+"/auth/local";
      http.Response response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(<String, String>{
            'identifier': emailLoginController.text,
            'password': passwordLoginController.text
          }));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ('Failed to load post');
      }
    }

    loginError(context) async {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Email y/o Contraseña Incorrecta')));
    }

    loginSuccess(response) async {
      token = await auth.setToken(response['jwt']);
      patientId =
          await auth.setPatientId(response['user']['patient']['id'].toString());
      Map<String, dynamic> responseNew;
      try {
        responseNew = await getResponseBookMedicalConsultation();
        formSuccess(responseNew);
      } catch (error) {
        formError(context, error);
      }
    }

    Widget loginButton() {
      return Container(
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 15.0),
          child: Builder(
              builder: (context) => SizedBox(
                    height: 40,
                    child: RaisedButton(
                      color: Colors.cyan[700],
                      onPressed: () async {
                        if (formKeyLogin.currentState.validate()) {
                          Map<String, dynamic> response;
                          try {
                            response = await getResponse();
                            if (response['user']['role']['type'] == 'patient') {
                              loginSuccess(response);
                            } else {
                              loginError(context);
                            }
                          } catch (error) {
                            loginError(context);
                          }
                        }
                      },
                      child: Text('Reservar',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )));
    }

    linkCreateAccount() {
      return Center(
          child: Column(
        children: [
          Text("¿No estás registrado?"),
          SizedBox(
            height: 5,
          ),
          InkWell(
              child: RichText(
                text: new TextSpan(
                    text: 'Reserva creando una cuenta',
                    style: TextStyle(
                      color: Colors.cyan[900],
                      decoration: TextDecoration.underline,
                    )),
              ),
              onTap: () {
                setState(() {
                  emailLoginController.clear();
                  passwordLoginController.clear();
                  formLoginIsVisible = false;
                  formCreatePatientIsVisible = true;
                });
                FocusScope.of(context).unfocus();
              })
        ],
      ));
    }

    Widget titleCreatePatient() {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
          child: Text(
            "Crea tu cuenta",
            style: new TextStyle(
                color: Colors.cyan[700],
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    Widget emailCreatePatientInput() {
      return Expanded(
        flex: 3,
        child: new TextFormField(
            controller: emailCreatePatientController,
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
              contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
              hintText: 'Correo Electrónico',
              labelText: 'Correo Electrónico',
            ),
            validator: (value) {
              if (email.isValidEmail(value)) {
                return 'Correo Electrónico inválido';
              }
              return null;
            }),
      );
    }

    Widget passwordCreatePatientInput() {
      return Expanded(
        flex: 2,
        child: new TextFormField(
            controller: passwordCreatePatientController,
            maxLines: 1,
            obscureText: true,
            autofocus: false,
            decoration: new InputDecoration(
              contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
              hintText: 'Contraseña',
              labelText: 'Contraseña',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Falta contraseña';
              }
              if (value.length < 7) {
                return '> 6 carácteres';
              }
              return null;
            }),
      );
    }

    Widget firstnameInput() {
      return Expanded(
        flex: 1,
        child: new TextFormField(
            controller: firstnameController,
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
              contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
              hintText: 'Nombres del doctor',
              labelText: 'Nombres',
            ),
            validator: (value) {
              if (value == '') {
                return 'Ingrese un nombre';
              }
              return null;
            }),
      );
    }

    Widget lastnameInput() {
      return Expanded(
        flex: 1,
        child: new TextFormField(
            controller: lastnameController,
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
              contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
              hintText: 'Apellidos del doctor',
              labelText: 'Apellidos',
            ),
            validator: (value) {
              if (value == '') {
                return 'Ingrese los apellidos';
              }
              return null;
            }),
      );
    }

    Widget genderInput() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Género",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          Container(
              height: 12,
              child: Row(
                children: [
                  Row(
                    children: [
                      Radio(
                        value: 0,
                        groupValue: genderValue,
                        onChanged: (value) {
                          setState(() {
                            genderValue = value;
                          });
                        },
                      ),
                      Text('Masculino',
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 1,
                        groupValue: genderValue,
                        onChanged: (value) {
                          setState(() {
                            genderValue = value;
                          });
                        },
                      ),
                      Text('Femenino',
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  )
                ],
              ))
        ],
      );
    }

    Widget phoneInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 10, 0.0, 10),
        child: new TextFormField(
            keyboardType: TextInputType.number,
            controller: phoneController,
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
              contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
              hintText: 'Ingresa tu teléfono',
              labelText: 'Teléfono',
            ),
            validator: (value) {
              if (value.length < 7) {
                return 'El teléfono debe tener más de 6 dígitos';
              }
              return null;
            }),
      );
    }

    Future<String> getResponsePatientsJSON(response) async {
      Completer<String> completer = Completer();
      response.stream.transform(utf8.decoder).listen((value) {
        completer.complete(value);
      });
      return completer.future;
    }

    Future<dynamic> getResponsePatients() async {
      var request = http.MultipartRequest(
          'POST', Uri.parse(auth.getIpAddress()+"/patients"));
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['email'] = emailCreatePatientController.text;
      data['password'] = passwordCreatePatientController.text;
      data['firstname'] = firstnameController.text;
      data['lastname'] = lastnameController.text;
      data['gender'] = genderValue;
      data['phone'] = phoneController.text;
      request.fields['data'] = json.encode(data);
      var response = await request.send();
      var responseJsonString = await getResponsePatientsJSON(response);
      Map<String, dynamic> responseJson = json.decode(responseJsonString);
      if (responseJson['statusCode'] != 400) {
        return responseJson;
      } else {
        throw responseJson['message'];
      }
    }

    Future<dynamic> getResponseLogin() async {
      String url = auth.getIpAddress()+"/auth/local";
      http.Response response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(<String, String>{
            'identifier': emailCreatePatientController.text,
            'password': passwordCreatePatientController.text
          }));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ('Failed to load post');
      }
    }

    formSuccessCreatePatient(response) async {
      Map<String, dynamic> responseLogin = await getResponseLogin();
      token = await auth.setToken(responseLogin['jwt']);
      patientId = await auth
          .setPatientId(responseLogin['user']['patient']['id'].toString());
      Map<String, dynamic> responseNew;
      try {
        responseNew = await getResponseBookMedicalConsultation();
        formSuccess(responseNew);
      } catch (error) {
        formError(context, error);
      }
    }

    Widget formCreatePatientButton() {
      return Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: Builder(
              builder: (context) => SizedBox(
                    height: 40.0,
                    child: RaisedButton(
                      color: Colors.cyan[700],
                      onPressed: () async {
                        if (formKeyCreatePatient.currentState.validate()) {
                          Map<String, dynamic> response;
                          try {
                            response = await getResponsePatients();
                            formSuccessCreatePatient(response);
                          } catch (error) {
                            formError(context, error);
                          }
                        }
                      },
                      child: Text('Reservar',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )));
    }

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text('Reservar Consulta Médica',
                style: TextStyle(color: Colors.white))),
        body: Stack(
          children: [
            Container(
                padding: EdgeInsets.all(30.0),
                child: Container(
                    child: Form(
                  key: formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      specialtyInput(),
                      doctorInput(),
                      dateInput(),
                      timeInput(),
                      formButton()
                    ],
                  ),
                ))),
            formLoginIsVisible == true
                ? Container(
                    color: Colors.black.withOpacity(0.1),
                    child: Container(
                        child: Center(
                            child: Stack(
                      children: [
                        Container(
                            margin: EdgeInsets.all(10.0),
                            padding: EdgeInsets.all(30.0),
                            color: Colors.white,
                            height: 390,
                            width: 320,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Form(
                                  key: formKeyLogin,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      titleLogin(),
                                      emailInput(),
                                      passwordInput(),
                                      loginButton(),
                                      linkCreateAccount()
                                    ],
                                  ),
                                )
                              ],
                            )),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: Material(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.cyan[700],
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  radius: 25,
                                  onTap: () async {
                                    emailLoginController.clear();
                                    passwordLoginController.clear();
                                    setState(() {
                                      formLoginIsVisible = false;
                                    });
                                  },
                                  splashColor: Colors.cyan[600],
                                  highlightColor: Colors.cyan[600],
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    child: Icon(
                                      Icons.close,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))),
                      ],
                    ))),
                  )
                : Container(),
            formCreatePatientIsVisible == true
                ? Container(
                    color: Colors.black.withOpacity(0.1),
                    child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: Center(
                            child: Stack(
                          children: [
                            Container(
                                margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.all(30.0),
                                color: Colors.white,
                                height: 430,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Form(
                                      key: formKeyCreatePatient,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          titleCreatePatient(),
                                          Container(
                                            margin:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                            child: Row(
                                              children: [
                                                emailCreatePatientInput(),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                passwordCreatePatientInput()
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 0, 0, 15),
                                            child: Row(
                                              children: [
                                                firstnameInput(),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                lastnameInput(),
                                              ],
                                            ),
                                          ),
                                          genderInput(),
                                          phoneInput(),
                                          formCreatePatientButton()
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: Material(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.cyan[700],
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      radius: 25,
                                      onTap: () async {
                                        emailCreatePatientController.clear();
                                        passwordCreatePatientController.clear();
                                        firstnameController.clear();
                                        lastnameController.clear();
                                        genderValue = 0;
                                        phoneController.clear();
                                        setState(() {
                                          formCreatePatientIsVisible = false;
                                        });
                                      },
                                      splashColor: Colors.cyan[600],
                                      highlightColor: Colors.cyan[600],
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        child: Icon(
                                          Icons.close,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))),
                          ],
                        ))),
                  )
                : Container()
          ],
        ),
        bottomNavigationBar: BottomBar.bottomNavigationBar(context));
  }
}

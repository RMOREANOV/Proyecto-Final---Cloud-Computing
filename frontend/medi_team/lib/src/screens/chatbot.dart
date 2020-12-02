import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api/notificationController.dart' as notificationController;
import '../api/timeController.dart' as timeController;

class Chatbot extends StatefulWidget {
  Chatbot({Key key}) : super(key: key);

  @override
  ChatbotState createState() => ChatbotState();
}

class ChatbotState extends State<Chatbot> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer clockTimerNotification;

  bool isIgnored = false;
  final formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  String question = "";
  String answer = "";
  List<dynamic> showData;

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

  Widget questionInput() {
    return Expanded(
      child: new TextFormField(
          controller: questionController,
          maxLines: 1,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Escribe tu pregunta...',
            hintStyle: TextStyle(fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(8),
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            if (value.length > 3) {
              setState(() {
                isIgnored = true;
              });
            } else {
              setState(() {
                isIgnored = false;
              });
            }
          }),
    );
  }

  Future<dynamic> getResponse() async {
    String url = "http://10.0.2.2:1337/patients/chatbotAnswer";
    http.Response response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(<String, String>{'question': question}));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw "El ChatBot no se encuentra disponible en este momento";
    }
  }

  formError(context, error) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  formSuccess(response) async {}

  Widget formButton() {
    return Container(
        width: 50.0,
        height: 50.0,
        child: Builder(
            builder: (context) => IgnorePointer(
                  ignoring: !isIgnored,
                  child: OutlineButton(
                    borderSide: BorderSide(
                        color: !isIgnored
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.6)),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        question = questionController.text;
                        answer = "";
                        questionController.text = "";
                        isIgnored = false;
                      });
                      String response;
                      try {
                        response = await getResponse();
                        setState(() {
                          answer = response;
                        });
                        formSuccess(answer);
                      } catch (error) {
                        formError(context, error);
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: !isIgnored
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.6),
                    ),
                    highlightedBorderColor: Colors.cyan[700],
                  ),
                )));
  }

  @override
  Widget build(BuildContext context) {
    showData = <dynamic>[];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CHAT BOT'),
      ),
      body: Container(
          color: Colors.cyan.withOpacity(0.05),
          width: double.infinity,
          padding: EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage('assets/images/chatbot_question.png'),
                    width: double.infinity,
                  ),
                  question != ""
                      ? Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.cyan[700].withOpacity(1))),
                          child: Row(
                            children: [
                              Flexible(
                                  fit: FlexFit.tight,
                                  child: new Text(question,
                                      textAlign: TextAlign.justify,
                                      style: new TextStyle(
                                          fontSize: 17,
                                          color: Colors.cyan[700]
                                              .withOpacity(1)))),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                  width: 65,
                                  height: 65,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Image.asset(
                                          'assets/images/patient_color.jpg')),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color:
                                              Colors.cyan[700].withOpacity(1))))
                            ],
                          ),
                        )
                      : Expanded(
                          child: Container(
                              child: Opacity(
                            opacity: 0.25,
                            child: Image(
                              image: AssetImage('assets/images/question.png'),
                            ),
                          )),
                        ),
                  answer != ""
                      ? Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5))),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      width: 65,
                                      height: 65,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          child: Image.asset(
                                              'assets/images/chatbot.jpg')),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.black
                                                  .withOpacity(0.5)))),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      child: new Text(answer,
                                          textAlign: TextAlign.justify,
                                          style: new TextStyle(
                                              color: Colors.black
                                                  .withOpacity(1)))),
                                ],
                              ),
                              (answer != "" && answer.contains('número'))
                                  ? Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Material(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: Colors.green.withOpacity(0.15),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            radius: 25,
                                            onTap: () {
                                              launch("tel:" +
                                                  answer.substring(19, 28));
                                            },
                                            splashColor:
                                                Colors.black.withOpacity(0.1),
                                            highlightColor:
                                                Colors.black.withOpacity(0.1),
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              child: Icon(
                                                Icons.call,
                                                size: 16,
                                                color: Colors.green
                                                    .withOpacity(0.75),
                                              ),
                                            ),
                                          )))
                                  : Container()
                            ],
                          ))
                      : Container(),
                  Container(
                    height: 50,
                  )
                ],
              ),
              Positioned(
                  child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  width: double.infinity,
                  child: Form(
                    key: formKey,
                    child: Row(
                      children: [
                        questionInput(),
                        SizedBox(
                          width: 10,
                        ),
                        formButton()
                      ],
                    ),
                  ),
                ),
              ))
            ],
          )),
      bottomNavigationBar: BottomBar.bottomNavigationBar(context),
    );
  }
}

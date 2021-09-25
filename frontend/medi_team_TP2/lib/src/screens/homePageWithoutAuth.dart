import 'package:flutter/material.dart';
import 'package:medi_team/src/screens/bookMedicalConsultation.dart';
import 'package:medi_team/src/screens/login.dart';

import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import 'package:medi_team/src/api/navigatorPush.dart' as NavigatorPush;

class HomePageWithoutAuth extends StatefulWidget {
  HomePageWithoutAuth({Key key}) : super(key: key);

  @override
  HomePageWithoutAuthState createState() => HomePageWithoutAuthState();
}

class HomePageWithoutAuthState extends State<HomePageWithoutAuth> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('INICIO'),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                height: 180,
                child: Image(
                  image: Image.network('https://medi-team.s3.amazonaws.com/login.png').image,
                  width: double.infinity,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                width: double.infinity,
                child: FlatButton(
                  height: 50,
                  color: Colors.cyan[700],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Colors.cyan[800],
                      )),
                  textColor: Colors.white,
                  onPressed: () async {
                    NavigatorPush.navigatorPushReplacement(
                        context, BookMedicalConsultation());
                  },
                  child: Text(
                    "Reservar Consulta Médica",
                    style: new TextStyle(fontSize: 22),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: InkWell(
                    child: RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(text: '¿Tienes una cuenta? '),
                          new TextSpan(
                              text: 'Inicia Sesión.',
                              style: TextStyle(
                                color: Colors.cyan[900],
                                decoration: TextDecoration.underline,
                              )),
                        ],
                      ),
                    ),
                    onTap: () {
                      NavigatorPush.navigatorPushReplacement(context, Login());
                      ;
                    }),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: 180,
                child: Image(
                  image: Image.network('https://medi-team.s3.amazonaws.com/homepage_message.png').image,
                  width: double.infinity,
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomBar.bottomNavigationBar(context));
  }
}

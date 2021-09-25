import 'dart:ui';

import 'package:medi_team/src/screens/createPatient.dart';
import 'package:medi_team/src/screens/homePageWithAuth.dart';

import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import '../api/navigatorPush.dart' as NavigatorPush;

import '../api/auth.dart' as auth;
import '../api/email.dart' as email;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget logo() {
      return Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
          child: Image(
            image: Image.network('https://medi-team.s3.amazonaws.com/login.png').image,
            height: MediaQuery.of(context).size.width * 0.4,
          ),
        ),
      );
    }

    Widget emailInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
        child: new TextFormField(
            controller: emailController,
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
            controller: passwordController,
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
            'identifier': emailController.text,
            'password': passwordController.text
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
      await auth.setToken(response['jwt']);
      await auth.setPatientId(response['user']['patient']['id'].toString());
      FocusScope.of(context).unfocus();
      NavigatorPush.navigatorPushReplacement(context, HomePageWithAuth());
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
                        if (formKey.currentState.validate()) {
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
                      child: Text('INGRESAR',
                          style: TextStyle(color: Colors.white)),
                    ),
                  )));
    }

    linkCreateAccount() {
      return Center(
        child: InkWell(
            child: RichText(
              text: new TextSpan(
                style: new TextStyle(
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  new TextSpan(text: '¿No estás registrado? '),
                  new TextSpan(
                      text: 'Crea una cuenta.',
                      style: TextStyle(
                        color: Colors.cyan[900],
                        decoration: TextDecoration.underline,
                      )),
                ],
              ),
            ),
            onTap: () {
              formKey.currentState.reset();
              emailController.clear();
              passwordController.clear();
              FocusScope.of(context).unfocus();
              NavigatorPush.navigatorPushReplacement(context, CreatePatient());
            }),
      );
    }

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title:
                Text('Iniciar Sesión', style: TextStyle(color: Colors.white))),
        body: Container(
            padding: EdgeInsets.all(30.0),
            child: Center(
                child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  logo(),
                  emailInput(),
                  passwordInput(),
                  loginButton(),
                  linkCreateAccount()
                ],
              ),
            ))),
        bottomNavigationBar: BottomBar.bottomNavigationBar(context));
  }
}

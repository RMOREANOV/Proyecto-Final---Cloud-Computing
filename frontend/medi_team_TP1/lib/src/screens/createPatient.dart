import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:medi_team/src/screens/homePageWithAuth.dart';

import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import 'package:medi_team/src/api/navigatorPush.dart' as NavigatorPush;
import 'package:mime/mime.dart';

import '../api/auth.dart' as auth;
import '../api/email.dart' as email;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class CreatePatient extends StatefulWidget {
  CreatePatient({Key key}) : super(key: key);

  @override
  CreatePatientState createState() => CreatePatientState();
}

class CreatePatientState extends State<CreatePatient> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  int genderValue = 0;
  File picture;
  final picker = ImagePicker();
  final phoneController = TextEditingController();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        picture = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget emailInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.5),
        child: new TextFormField(
            controller: emailController,
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
              contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
              hintText: 'Correo Electrónico',
              labelText: 'Correo Electrónico',
            ),
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
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.5),
        child: new TextFormField(
            controller: passwordController,
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
                return 'Ingrese alguna contraseña';
              }
              if (value.length < 7) {
                return 'La contraseña debe tener más de 6 carácteres';
              }
              return null;
            }),
      );
    }

    Widget firstnameInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.5),
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
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Género",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          Container(
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

    Widget photoInput() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Foto",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
              ),
            ),
            child: Image(
              image: picture == null
                  ? AssetImage('assets/images/patient.jpg')
                  : FileImage(picture),
              height: 100,
              width: 100,
            ),
          ),
          OutlineButton(
            borderSide: BorderSide(color: Colors.black),
            color: Colors.black,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              getImage();
            },
            child: Text('Seleccionar foto...',
                style: TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ],
      );
    }

    Widget phoneInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.5),
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
      var mimeTypeData;
      var multipartFile;
      if (picture != null) {
        mimeTypeData =
            lookupMimeType(picture.path, headerBytes: [0xFF, 0xD8]).split('/');
        multipartFile = new http.MultipartFile(
            'files.photo',
            http.ByteStream(Stream.castFrom(picture.openRead())),
            picture.readAsBytesSync().length,
            filename: basename(picture.path),
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
      }
      var request = http.MultipartRequest(
          'POST', Uri.parse("http://10.0.2.2:1337/patients"));
      if (picture != null) {
        request.files.add(multipartFile);
      }
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['email'] = emailController.text;
      data['password'] = passwordController.text;
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
      String url = "http://10.0.2.2:1337/auth/local";
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

    formError(context, error) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(error)));
    }

    formSuccess(response) async {
      Map<String, dynamic> responseLogin = await getResponseLogin();
      await auth.setToken(responseLogin['jwt']);
      await auth
          .setPatientId(responseLogin['user']['patient']['id'].toString());
      FocusScope.of(context).unfocus();
      Navigator.pop(context);
      NavigatorPush.navigatorPushReplacement(context, HomePageWithAuth());
    }

    Widget formButton() {
      return Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: Builder(
              builder: (context) => SizedBox(
                    width: double.infinity,
                    height: 40.0,
                    child: OutlineButton(
                      borderSide: BorderSide(color: Colors.black),
                      color: Colors.black,
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          Map<String, dynamic> response;
                          try {
                            response = await getResponsePatients();
                            formSuccess(response);
                          } catch (error) {
                            formError(context, error);
                          }
                        }
                      },
                      child:
                          Text('CREAR', style: TextStyle(color: Colors.black)),
                    ),
                  )));
    }

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text('Crear Cuenta', style: TextStyle(color: Colors.white))),
        body: Container(
            padding: EdgeInsets.fromLTRB(30.0, 20.0, 20.0, 30.0),
            child: Container(
                child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  emailInput(),
                  passwordInput(),
                  firstnameInput(),
                  lastnameInput(),
                  genderInput(),
                  photoInput(),
                  phoneInput(),
                  formButton()
                ],
              ),
            ))),
        bottomNavigationBar: BottomBar.bottomNavigationBar(context));
  }
}

import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:medi_team/src/screens/homePageWithAuth.dart';
import 'package:medi_team/src/widgets/bottomBar.dart' as BottomBar;
import 'package:medi_team/src/api/navigatorPush.dart' as NavigatorPush;
import 'package:medi_team/src/screens/homePageWithoutAuth.dart';
import 'package:mime/mime.dart';

import '../api/auth.dart' as auth;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class EditPatient extends StatefulWidget {
  final patient;
  EditPatient({Key key, this.patient}) : super(key: key);

  @override
  EditPatientState createState() => EditPatientState(patient);
}

class EditPatientState extends State<EditPatient> {
  final patient;
  List<dynamic> specialties = [];
  final formKey = GlobalKey<FormState>();
  var firstnameController = TextEditingController();
  var lastnameController = TextEditingController();
  int genderValue = 0;
  File picture;
  var phoneController = TextEditingController();
  final picker = ImagePicker();
  EditPatientState(this.patient);

  @override
  void initState() {
    firstnameController = TextEditingController(text: patient['firstname']);
    lastnameController = TextEditingController(text: patient['lastname']);
    genderValue = patient['gender']['name'] == "Male" ? 0 : 1;
    phoneController = TextEditingController(text: patient['phone']);
    super.initState();
  }

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
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.5),
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
              child: (patient == null ||
                      (patient != null && picture != null) ||
                      patient['photo'] == null)
                  ? Image(
                      image: picture == null
                          ? AssetImage('assets/images/patient.jpg')
                          : FileImage(picture),
                      height: 100,
                      width: 100,
                    )
                  : Image.network(
                      'http://10.0.2.2:1337' + patient['photo']['url'],
                      height: 100,
                      width: 100)),
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
              hintText: 'Teléfono del doctor',
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

    Future<String> getResponseJSON(response) async {
      Completer<String> completer = Completer();
      response.stream.transform(utf8.decoder).listen((value) {
        completer.complete(value);
      });
      return completer.future;
    }

    Future<dynamic> getResponse() async {
      String token = await auth.getToken();
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
      int patientId = patient['id'];
      var request = http.MultipartRequest(
          'PUT', Uri.parse("http://10.0.2.2:1337/patients/$patientId"));
      request.headers.addAll({
        "Authorization": 'Bearer $token',
      });
      if (picture != null) {
        request.files.add(multipartFile);
      }
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['firstname'] = firstnameController.text;
      data['lastname'] = lastnameController.text;
      data['gender'] = genderValue;
      data['phone'] = phoneController.text;
      request.fields['data'] = json.encode(data);
      var response = await request.send();
      var responseJsonString = await getResponseJSON(response);
      Map<String, dynamic> responseJson = json.decode(responseJsonString);
      if (responseJson['statusCode'] != 400) {
        return responseJson;
      } else {
        throw responseJson['message'];
      }
    }

    formError(context, error) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(error)));
    }

    formSuccess(response) async {
      FocusScope.of(context).unfocus();
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
                            response = await getResponse();
                            formSuccess(response);
                          } catch (error) {
                            formError(context, error);
                          }
                        }
                      },
                      child: Text('GUARDAR',
                          style: TextStyle(color: Colors.black)),
                    ),
                  )));
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Editar Doctor'),
        ),
        body: Container(
            padding: EdgeInsets.all(30.0),
            child: Container(
                child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
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

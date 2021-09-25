import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medi_team/src/screens/homePageWithAuth.dart';
import 'package:medi_team/src/screens/homePageWithoutAuth.dart';

import 'src/api/auth.dart' as auth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String token = await auth.getToken();
  runApp(App(token));
}

class App extends StatelessWidget {
  final String token;
  App(this.token);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.cyan[700],
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        MethodChannel('samples.flutter.dev/flags')
            .invokeMethod('disableFullscreen'));
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
            iconTheme: IconThemeData(
              color: Colors.white,
            )),
        primaryColor: Colors.cyan[600],
        accentColor: Colors.cyan[600],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: token == null ? HomePageWithoutAuth() : HomePageWithAuth(),
    );
  }
}

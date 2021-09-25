import 'package:shared_preferences/shared_preferences.dart';

const TOKEN_KEY = 'jwtToken';
const USER_INFO = 'userInfo';

set(value, key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(key, value);
  return value;
}

Future<String> get(value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(value);
}

clearAppStorage() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

import './sharedPreferences.dart' as SharedPreferences;

const TOKEN_KEY = 'jwtToken';
const DOCTOR_ID = 'doctorId';
const PATIENT_ID = 'patientId';

Future<String> setToken(value) async {
  await SharedPreferences.set(value, TOKEN_KEY);
  return value;
}

Future<String> setDoctorId(value) async {
  await SharedPreferences.set(value, DOCTOR_ID);
  return value;
}

Future<String> setPatientId(value) async {
  await SharedPreferences.set(value, PATIENT_ID);
  return value;
}

Future<String> getToken() async {
  String token = await SharedPreferences.get(TOKEN_KEY);
  return token;
}

Future<String> getDoctorId() async {
  String userId = await SharedPreferences.get(DOCTOR_ID);
  return userId;
}

Future<String> getPatientId() async {
  String userId = await SharedPreferences.get(PATIENT_ID);
  return userId;
}

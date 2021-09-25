import './sharedPreferences.dart' as SharedPreferences;

const MEDICAL_CONSULTATION_CLOSE = 'medicalConsultationClose';

Future<String> setMedicalConsultationClose(value) async {
  await SharedPreferences.set(value, MEDICAL_CONSULTATION_CLOSE);
  return value;
}

Future<String> getMedicalConsultationClose() async {
  String token = await SharedPreferences.get(MEDICAL_CONSULTATION_CLOSE);
  return token;
}

String dateTimeToTitle(DateTime datetime) {
  var months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  var days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];
  var monthInt = datetime.month;
  var dayInt = datetime.weekday;

  return days[dayInt - 1] +
      ", " +
      datetime.day.toString() +
      " de " +
      months[monthInt - 1] +
      " de " +
      datetime.year.toString();
}

String datetimeToSubtitle(DateTime datetime) {
  var hour = datetime.hour;
  var minute = datetime.minute;
  var newHourString = "00" + (hour <= 12 ? hour : hour - 12).toString();
  var newMinuteString = "00" + minute.toString();
  var detectAMorPM = hour < 12 ? "AM" : "PM";
  return newHourString.substring(
          newHourString.length - 2, newHourString.length) +
      ":" +
      newMinuteString.substring(
          newMinuteString.length - 2, newMinuteString.length) +
      " " +
      detectAMorPM;
}

bool isMedicalConsultationNow(DateTime dateTime) {
  DateTime now = DateTime.now();
  if (now.millisecondsSinceEpoch > dateTime.millisecondsSinceEpoch) {
    return true;
  }
  return false;
}

bool isMedicalConsultationClose(DateTime dateTime) {
  DateTime now = DateTime.now();
  if (now.millisecondsSinceEpoch >
      dateTime.millisecondsSinceEpoch - 3 * 60 * 60 * 1000) {
    return true;
  }
  return false;
}

bool isDateNowEvery30Minutes() {
  DateTime now = DateTime.now();
  if (now.minute == 0 || now.minute == 30) {
    return true;
  }
  return false;
}

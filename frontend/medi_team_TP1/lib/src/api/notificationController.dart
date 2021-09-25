import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api/timeController.dart' as timeController;

dynamic initializeNotification(flutterLocalNotificationsPlugin) {
  var androidInitialize = new AndroidInitializationSettings('launcher_icon');
  var iosInitialize = new IOSInitializationSettings();
  var initializationsSettings = new InitializationSettings(
      android: androidInitialize, iOS: iosInitialize);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  return flutterLocalNotificationsPlugin;
}

Future showNotification(flutterLocalNotificationsPlugin) async {
  var medicalConsultationClose =
      await timeController.getMedicalConsultationClose();
  if (medicalConsultationClose != null) {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Main", "My main channel",
        importance: Importance.max);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    var time = DateTime.parse(medicalConsultationClose).toLocal();
    var timeString = timeController.datetimeToSubtitle(time);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Medi Team',
        time.hour == 1
            ? 'No olvides tu consulta médica a la '
            : 'No olvides tu consulta médica a las ' + timeString,
        generalNotificationDetails);
  }
}

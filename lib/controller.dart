import 'package:firebase_database/firebase_database.dart';
import 'package:naqi_app/firebase.dart';
import 'package:naqi_app/fan.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:naqi_app/firebase.dart';
import 'package:naqi_app/indoorAirQuality.dart';

class Controller {
  bool notificationSent = false;
  String status = '';
  String isSwitchOn = '';
  String atomatic = '';
  FirebaseService firebase = FirebaseService();
  Fan fan = Fan();
  // bool switchStatus = IndoorPage.getSwitchStatus();
  void checkIndoorAirQualityData(var co2) {
    // Get fan status and switch status from databse
    Future<String> fanStatus = firebase.getStatus();
    Future<String> isAutomatic = firebase.isAutomatic();

    fanStatus.then((value) {
      status = value;

      isAutomatic.then((value) {
        atomatic = value;
        // check CO2 and fan status
        if ((co2 > 1000) & (status == '0')) {
          fan.turnOn();
          fan.updateisAutomatic(1);
          fan.updateSwitch(1);

          sendNotification(
              "مستوى ثاني أكسيد الكربون مرتفع! سيتم تشغيل المروحة");
        } // check CO2 and fan status and switch status
        else if ((co2 <= 1000) & (atomatic == '1')) {
          fan.turnOff();
          fan.updateisAutomatic(0);
          fan.updateSwitch(0);
          sendNotification("مستوى ثاني أكسيد الكربون جيد! سيتم ايقاف المروحة");
        }
      });
    });
  }

  void checkOutdoorAirQuality(var dust) {
    // Get user health status imformation from databse
    bool healthStaus = FirebaseService.healthStatus;
    String healthStatusLevel = FirebaseService.healthStatusLevel;
    print(notificationSent);
    // check to see if a notification has already been sent
    if (!notificationSent) {
      // check pm value based on user health status
      if (healthStaus == true) {
        if ((healthStatusLevel == 'شديد') && (dust >= 15000)) {
          sendNotification('جودة الهواء: ملوث بالنسبة لحالتك الصحية');
          notificationSent = true;
        }
        if ((healthStatusLevel == 'متوسط') && (dust >= 20000)) {
          sendNotification('جودة الهواء: ملوث بالنسبة لحالتك الصحية');
          notificationSent = true;
        }
        if ((healthStatusLevel == 'خفيف') && (dust >= 25000)) {
          sendNotification('جودة الهواء: ملوث بالنسبة لحالتك الصحية');
          notificationSent = true;
        }
      } else {
        if (dust > 30000) {
          sendNotification('جودة الهواء: ملوث');
          notificationSent = true;
        }
      }
    }
    // If a notification has already been sent
    // check to see if the dust value returns to its normal value
    if (notificationSent) {
      if (healthStaus == true) {
        if ((healthStatusLevel == 'شديد') && (dust < 15000)) {
          notificationSent = false;
        }
        if ((healthStatusLevel == 'متوسط') && (dust < 20000)) {
          notificationSent = false;
        }
        if ((healthStatusLevel == 'خفيف') && (dust < 25000)) {
          notificationSent = false;
        }
      } else {
        if (dust <= 30000) {
          notificationSent = false;
        }
      }
    }
  }

  void sendNotification(String text) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10, channelKey: "default_channel", title: "تنبيه!", body: text),
    );
  }
}

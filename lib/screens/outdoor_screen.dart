import 'dart:convert';
import 'package:naqi_app/outdoorAirQuality.dart';
import 'package:flutter/material.dart';
import 'package:naqi_app/fan.dart';
import 'package:naqi_app/controller.dart';
import 'package:naqi_app/firebase.dart';
import 'package:naqi_app/sensor.dart';

class OutdoorPage extends StatefulWidget {
  OutdoorPage({Key? key}) : super(key: key);

  @override
  _OutdoorPageState createState() => _OutdoorPageState();
}

class _OutdoorPageState extends State<OutdoorPage>
    with AutomaticKeepAliveClientMixin {
  static bool notificationSent = false;
  Controller controller = Controller();

  @override
  void initState() {
    super.initState();
    //Listen to the stream
    sensor.getOutdoorReadings().listen((data) {
      // This callback function is called every time new data is received from the stream
      var jsonData = jsonDecode(data);
      List<dynamic> reading = sensorReadings.readData(jsonData);
      var co2 = reading[2];
      controller.checkAirQualityData(co2);
      //var pm = reading[4];
      //controller.checkOutdoorAirQuality(pm);
    });

    // يمكن نحتاجها لو سوينا ايديت اي دي
    /*Future<String> indoorSensorID = firebase.getIndoorSensorID();
    indoorSensorID.then((value) {
      setState(() {
        indoorSensorID1 = value;
        FirebaseService.indoorSensorID = indoorSensorID1;
      });
      Future<String> indoorSensorURL =
          firebase.getIndoorSensorURL(indoorSensorID1);
      indoorSensorURL.then((value) {
        setState(() {
          indoorSensorUrl = value;
          FirebaseService.indoorSensorURL = indoorSensorUrl;
        });
      });
    });

   Future<String> outdoorSensorID = firebase.getOudoorSensorID();
    outdoorSensorID.then((value) {
      setState(() {
        outdoorSensorID1 = value;
        FirebaseService.outdoorSensorID = outdoorSensorID1;
      });
      Future<String> outdoorSensorURL =
          firebase.getOudoorSensorURL(outdoorSensorID1);
      outdoorSensorURL.then((value) {
        setState(() {
          outdoorSensorUrl = value;
          FirebaseService.outdoorSensorURL = outdoorSensorUrl;
        });
      });
    });*/
  }

  @override
  bool get wantKeepAlive => true;
  //OutdoorSensor sensor = OutdoorSensor();

  Sensor sensor = Sensor();
  Fan fan = Fan();
  OutdoorAirQuality sensorReadings = OutdoorAirQuality();
  FirebaseService firebase = FirebaseService();

  //String indoorSensorID1 = '';
  //String indoorSensorUrl = '';
  //String outdoorSensorID1 = '';
  //String outdoorSensorUrl = '';

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 0, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [],
              ),
              Expanded(
                child: Container(
                  height: 100.0,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 26),
                      StreamBuilder<String>(
                        stream: sensor.getOutdoorReadings(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            print("no data");
                            return Container(
                              height: 100,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          strokeWidth: 3.0,
                                        ),
                                        SizedBox(height: 16),
                                        RichText(
                                          text: TextSpan(
                                            text: 'بانتظار البيانات',
                                            style: TextStyle(
                                              color: Color(0xff45A1B6),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            var data = jsonDecode(snapshot.data.toString());
                            List<dynamic> readings =
                                sensorReadings.readData(data);
                            List<String> levels =
                                sensorReadings.calculateLevel(readings);

                            return Column(children: [
                              Row(
                                children: [
                                  sensorReadings.viewOutdoorAirQuality(
                                      readings, context),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  sensorReadings.checkTime(
                                      readings[3], context),
                                ],
                              ),
                            ]);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

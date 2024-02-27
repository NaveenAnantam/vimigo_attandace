import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xfff5b438);
  String clockIn = "--/--";
  String clockOut = "--/--";
  String location = "";
  late SharedPreferences sharedPreferences;
  String userName = '';

  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _getRecord();
    loadUserName();
  }

  void loadUserName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userName = sharedPreferences.getString('userName') ?? '';
    });
  }

  void _initPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(User.lat, User.long);
    setState(() {
      location =
          "${placemark[0].street}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode}, ${placemark[0].country}";
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('email', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      await prefs?.setString('clockIn', snap2['Clockin']);
      await prefs?.setString('clockOut', snap2['Clockout']);

      setState(() {
        clockIn = snap2['Clockin'];
        clockOut = snap2['Clockout'];
      });
    } catch (e) {
      setState(() {
        clockIn = "--/--";
        clockOut = "--/--";
      });
    }
  }

  void _updateClockIn(String clockInTime) async {
    await prefs?.setString('clockIn', clockInTime);
    setState(() {
      clockIn = clockInTime;
    });
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          prefs = snapshot.data;
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(
                      top: 32,
                    ),
                    child: Text(
                      'Welcome,',
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: "NexaRegular",
                        fontSize: screenWidth / 20,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontFamily: "NexaRegular",
                        fontSize: screenWidth / 13,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 32),
                    child: Text(
                      "Today's Status",
                      style: TextStyle(
                        fontFamily: "NexaBold",
                        fontSize: screenWidth / 10,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 34),
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Clock-In",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: "NexaRegular",
                                  fontSize: screenWidth / 20,
                                ),
                              ),
                              Text(
                                clockIn,
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: screenWidth / 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Clock-Out",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: "NexaRegular",
                                  fontSize: screenWidth / 20,
                                ),
                              ),
                              Text(
                                clockOut,
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: screenWidth / 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: DateTime.now().day.toString(),
                        style: TextStyle(
                            color: primary,
                            fontSize: screenWidth / 18,
                            fontFamily: "NexaBold"),
                        children: [
                          TextSpan(
                            text: DateFormat(' MMMM yy').format(DateTime.now()),
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: screenWidth / 20,
                                fontFamily: "NexaBold"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            DateFormat('hh:mm:ss a').format(DateTime.now()),
                            style: TextStyle(
                              fontFamily: "NexaRegular",
                              fontSize: screenWidth / 20,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }),
                  clockOut == "--/--"
                      ? Container(
                          margin: const EdgeInsets.only(top: 24, bottom: 12),
                          child: Builder(
                            builder: (context) {
                              final GlobalKey<SlideActionState> key =
                                  GlobalKey();
                              return SlideAction(
                                  text: clockIn == "--/--"
                                      ? "Slide to Clock In"
                                      : "Slide to Clock Out ",
                                  textStyle: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: "NexaRegular",
                                    fontSize: screenWidth / 20,
                                  ),
                                  outerColor: primary,
                                  innerColor: Colors.white,
                                  key: key,
                                  onSubmit: () async {
                                    if (User.lat != 0) {
                                      _getLocation();

                                      //Clock in or Clock Out
                                      QuerySnapshot snap =
                                          await FirebaseFirestore.instance
                                              .collection("Employee")
                                              .where('email',
                                                  isEqualTo: User.employeeId)
                                              .get();

                                      DocumentSnapshot snap2 =
                                          await FirebaseFirestore.instance
                                              .collection("Employee")
                                              .doc(snap.docs[0].id)
                                              .collection("Record")
                                              .doc(DateFormat('dd MMMM yyyy')
                                                  .format(DateTime.now()))
                                              .get();

                                      if (clockIn == "--/--") {
                                        // Clock in
                                        await FirebaseFirestore.instance
                                            .collection('Employee')
                                            .doc(snap.docs[0].id)
                                            .collection("Record")
                                            .doc(DateFormat('dd MMMM yyyy')
                                                .format(DateTime.now()))
                                            .set({
                                          'ClockIn': DateFormat('HH:MM')
                                              .format(DateTime.now()),
                                          'ClockOut': "--/--",
                                          'date': Timestamp.now(),
                                          'Location': location
                                        });

                                        setState(() {
                                          clockIn = DateFormat('hh:mm a')
                                              .format(DateTime.now());
                                        });
                                        await prefs?.setString(
                                            'clockIn', clockIn);
                                      } else {
                                        // Clock out
                                        await FirebaseFirestore.instance
                                            .collection("Employee")
                                            .doc(snap.docs[0].id)
                                            .collection("Record")
                                            .doc(DateFormat('dd MMMM yyyy')
                                                .format(DateTime.now()))
                                            .update({
                                          'ClockOut': DateFormat('HH:MM')
                                              .format(DateTime.now()),
                                          'date': Timestamp.now(),
                                          'Location': location
                                        });

                                        setState(() {
                                          clockOut = DateFormat('hh:mm a')
                                              .format(DateTime.now());
                                        });
                                        await prefs?.setString(
                                            'clockOut', clockOut);
                                      }
                                      ;
                                    } else {
                                      Timer(Duration(seconds: 3), () async {
                                        _getLocation();

                                        //Clock in or Clock Out
                                        QuerySnapshot snap =
                                            await FirebaseFirestore
                                                .instance
                                                .collection("Employee")
                                                .where('email',
                                                    isEqualTo: User.employeeId)
                                                .get();

                                        DocumentSnapshot snap2 =
                                            await FirebaseFirestore.instance
                                                .collection("Employee")
                                                .doc(snap.docs[0].id)
                                                .collection("Record")
                                                .doc(DateFormat('dd MMMM yyyy')
                                                    .format(DateTime.now()))
                                                .get();

                                        if (clockIn == "--/--") {
                                          // Clock in
                                          await FirebaseFirestore.instance
                                              .collection('Employee')
                                              .doc(snap.docs[0].id)
                                              .collection("Record")
                                              .doc(DateFormat('dd MMMM yyyy')
                                                  .format(DateTime.now()))
                                              .set({
                                            'ClockIn': DateFormat('HH:MM')
                                                .format(DateTime.now()),
                                            'ClockOut': "--/--",
                                            'date': Timestamp.now(),
                                            'Location': location
                                          });

                                          setState(() {
                                            clockIn = DateFormat('hh:mm a')
                                                .format(DateTime.now());
                                          });
                                        } else {
                                          // Clock out
                                          await FirebaseFirestore.instance
                                              .collection("Employee")
                                              .doc(snap.docs[0].id)
                                              .collection("Record")
                                              .doc(DateFormat('dd MMMM yyyy')
                                                  .format(DateTime.now()))
                                              .update({
                                            'ClockOut': DateFormat('HH:MM')
                                                .format(DateTime.now()),
                                            'date': Timestamp.now(),
                                            'Location': location
                                          });

                                          setState(() {
                                            clockOut = DateFormat('hh:mm a')
                                                .format(DateTime.now());
                                          });
                                        }
                                        ;
                                        key.currentState!.reset();
                                      });
                                    }
                                  });
                            },
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 32, bottom: 15),
                          padding: EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Text(
                            "You have already Checked Out today",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: "NexaRegular",
                              fontSize: screenWidth / 20,
                            ),
                          ),
                        ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 12),
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Center(
                      child: location != ""
                          ? Text(
                              'Location:' + location,
                              style: TextStyle(
                                color: Colors.black54,
                                fontFamily: "NexaRegular",
                                fontSize: screenWidth / 30,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return CircularProgressIndicator(); // Show a loading spinner while waiting for prefs to initialize
        }
      },
    );
  }
}

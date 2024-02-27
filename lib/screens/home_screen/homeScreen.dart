import 'package:vimigo_attandace/screens/home_screen/calendarScreen.dart';
import 'package:vimigo_attandace/screens/home_screen/profileScreen.dart';
import 'package:vimigo_attandace/screens/home_screen/todayScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/user.dart';
import '../../services/location_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xfff5b438);

  int currentIndex = 0;

  List<IconData> navigationIcons =[
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.userAlt,
  ];

  @override
  void initState() {
    super.initState();
    _startLocationService();
    getId();
  }

  void _startLocationService() async{
    LocationService().initialize();
    LocationService().getLongitude().then((value) {
      setState(() {
        User.long = value!;
      });

      LocationService().getLattitude().then((value) {
        setState(() {
          User.lat = value!;
        });
      });
    });
  }

  void getId() async{
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('Employee')
        .where('email', isEqualTo: User.employeeId).get();

    setState(() {
      User.id = snap.docs[0].id;
    });
  }



  @override
  Widget build(BuildContext context) {

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body:IndexedStack(
        index: currentIndex,
        children:  [
          new CalendarScreen(),
          new TodayScreen(),
          new ProfileScreen(),
        ],

      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        decoration:  const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow:[
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2,2),
            ),
          ],
        ),
        child:  ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i = 0; i <navigationIcons.length; i++)...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        currentIndex =i;
                      });
                    },
                    child: Container(
                      height: screenHeight,
                      width: screenWidth,
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              navigationIcons[i],
                              color: i == currentIndex ? primary : Colors.black54,
                              size: i == currentIndex ? 32:26,
                            ),
                            i == currentIndex ?Container(
                              margin: EdgeInsets.only(top: 6),
                              height: 3,
                              width: 24,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                              ),

                            ) :const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              },
            ],
          ),
        ),
      ),

    );
  }
}

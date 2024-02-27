import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../model/user.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xfff5b438);
  String _month = DateFormat('MMMM').format(DateTime.now());
  bool _useCustomFormat = false; // Toggle button state
  String _selectedMonth =
  DateFormat('MMMM').format(DateTime.now()).toLowerCase();

  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _filteredSnap = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPreferredFormat(); // Load user's preferred format
    _searchController.addListener(_filter);
    _filter(); // Fetch the data initially
  }

  // Load user's preferred format from persistent storage
  Future<void> _loadPreferredFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useCustomFormat = prefs.getBool('useCustomFormat') ?? false;
    });
  }

  // Save user's preferred format to persistent storage
  Future<void> _savePreferredFormat(bool useCustomFormat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCustomFormat', useCustomFormat);
  }

  // Format the date according to the user's preference
  String _formatDate(DateTime date) {
    final format =
    _useCustomFormat ? DateFormat(' h:mm a') : DateFormat('HH:mm');
    return format.format(date);
  }

  void _filter() {
    FirebaseFirestore.instance
        .collection('Employee')
        .doc(User.id)
        .collection("Record")
        .snapshots() // Listen for real-time updates
        .listen((QuerySnapshot querySnapshot) {
      List<DocumentSnapshot> snap = querySnapshot.docs;
      setState(() {
        if (_searchController.text.isEmpty) {
          // If the search bar is empty, show all data
          _filteredSnap = snap;
        } else {
          // If the search bar is not empty, filter the data
          _filteredSnap = snap.where((doc) {
            // Convert the Timestamp to a DateTime
            DateTime date = doc['date'].toDate();

            // Check if the day of the month matches the search text
            bool dayMatch =
                DateFormat('d').format(date) == _searchController.text;

            // Return true if the day matches
            return dayMatch;
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                top: 32,
              ),
              child: Text(
                'My Attendance',
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 15,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth =
                            value.toLowerCase(); // Update the selected month
                        _filter(); // Filter the data based on the selected month
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),

                  // Text explaining the setting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "12-Hour Format",
                        style: TextStyle(fontSize: 16, fontFamily: 'NexaBold'),
                      ),
                      Switch(
                        value: _useCustomFormat,
                        onChanged: (newValue) {
                          setState(() {
                            _useCustomFormat = newValue;
                            _savePreferredFormat(
                                newValue); // Save user's preference
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(
                    top: 32,
                  ),
                  child: Text(
                    _month,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: "NexaBold",
                      fontSize: screenWidth / 20,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(
                    top: 32,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      final month = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2099),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primary,
                                  secondary: primary,
                                  onSecondary: Colors.white,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(foregroundColor: primary),
                                ),
                                textTheme: TextTheme(
                                  titleMedium: TextStyle(
                                    fontFamily: "NexaBold",
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          });

                      if (month != null) {
                        setState(() {
                          _month = DateFormat('MMMM').format(month);
                          _selectedMonth =
                              _month.toLowerCase(); // Update the selected month
                          _filter(); // Filter the data based on the selected month
                        });
                      }
                    },
                    child: Text(
                      'Pick A Month',
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: "NexaBold",
                        fontSize: screenWidth / 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight / 1.95,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Employee')
                    .doc(User.id)
                    .collection("Record")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;
                    if (snap.isEmpty) {
                      return Center(child: Text('List is empty'));
                    } else {
                      return ListView.builder(
                        itemCount: _filteredSnap.isEmpty
                            ? 1
                            : _filteredSnap.length +
                            1, // Add one more item for the end-of-list indicator
                        itemBuilder: (context, index) {
                          if (index < _filteredSnap.length) {
                            DateTime? clockIn;
                            DateTime? clockOut;
                            // Convert the ClockIn and ClockOut data to DateTime objects
                            if (snap[index]['ClockIn'] != '--/--') {
                              clockIn = DateTime.parse(
                                  '1970-01-01 ${snap[index]['ClockIn']}');
                            }

                            if (snap[index]['ClockOut'] != '--/--') {
                              clockOut = DateTime.parse(
                                  '1970-01-01 ${snap[index]['ClockOut']}');
                            }

                            // Format the ClockIn and ClockOut times as strings
                            String clockInStr = clockIn != null
                                ? _formatDate(clockIn)
                                : '--/--';
                            String clockOutStr = clockOut != null
                                ? _formatDate(clockOut)
                                : '--/--';

                            // Calculate the time difference between now and the record's date
                            String timeAgo = timeago.format(
                                snap[index]['date'].toDate(),
                                locale: 'en_short');

                            return DateFormat('MMMM')
                                .format(snap[index]['date'].toDate()) ==
                                _month
                                ? Container(
                              margin: EdgeInsets.only(
                                  top: index > 0 ? 12 : 0,
                                  left: 6,
                                  right: 6),
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
                                borderRadius:
                                BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: primary,
                                      ),
                                      child: Center(
                                        child: Text(
                                          DateFormat('EE \n dd').format(
                                              snap[index]['date']
                                                  .toDate()),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "NexaBold",
                                            fontSize: screenWidth / 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Clock-In",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontFamily: "NexaRegular",
                                            fontSize: screenWidth / 28,
                                          ),
                                        ),
                                        Text(
                                          clockInStr,
                                          style: TextStyle(
                                            fontFamily: "NexaBold",
                                            fontSize: screenWidth / 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Clock-Out",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontFamily: "NexaRegular",
                                            fontSize: screenWidth / 28,
                                          ),
                                        ),
                                        Text(
                                          clockOutStr,
                                          style: TextStyle(
                                            fontFamily: "NexaBold",
                                            fontSize: screenWidth / 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Updated",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontFamily: "NexaRegular",
                                            fontSize: screenWidth / 28,
                                          ),
                                        ),
                                        Text(
                                          timeAgo + " ago",
                                          style: TextStyle(
                                            fontFamily: "NexaBold",
                                            fontSize: screenWidth / 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : const SizedBox();
                          } else {
                            // This will be your end-of-list indicator
                            return Container(
                              padding: const EdgeInsets.only(top: 25),
                              alignment: Alignment.center,
                              child: Text(
                                _filteredSnap.isEmpty
                                    ? "List is empty"
                                    : "-------------------------------------\nYou have reached the end of the list",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontFamily: "NexaRegular"),
                              ),
                            );
                          }
                        },
                      );
                    }
                  } else {
                    return Center(child: Text('List is empty'));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

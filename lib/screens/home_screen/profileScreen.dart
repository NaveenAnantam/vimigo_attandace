import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color primary = const Color(0xfff5b438);
  late SharedPreferences sharedPreferences;
  String userName = '';
  String userID = '';
  String userEmail = '';
  String userPhotoUrl = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final imageUrl = await FirebaseStorage.instance.ref('userProfile/${user.uid}').getDownloadURL();
      setState(() {
        userName = userData['name'];
        userID = userData['workerid'];
        userEmail = userData['email'];
        userPhotoUrl = imageUrl;
      });
    }
  }

  Future<void> updateUserPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final String fileName = basename(pickedFile.path);
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = tempDir.path;
      final File tempFile = File('$targetPath/$fileName');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ref = FirebaseStorage.instance.ref('userProfile/${user.uid}');
        await ref.putFile(tempFile);
        final imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('Employee').doc(user.uid).update({'photoUrl': imageUrl});

        setState(() {
          userPhotoUrl = imageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 80, bottom: 40),
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius:BorderRadius.circular(20),
                  color: primary
              ),
              child: userPhotoUrl.isNotEmpty
                  ? Image.network(userPhotoUrl)
                  : Icon(Icons.person, color: Colors.white, size: 80,),
            ),
            Align(
              alignment: Alignment.center,
              child:Text(
                'Employee ${userID}',
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 24,),
            Text(
              'Name: $userName',
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16,),
            Text(
              'Email: $userEmail',
              style: TextStyle(
                fontFamily: "NexaRegular",
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16,),
            ElevatedButton(
              onPressed: updateUserPhoto,
              child: Text('Change Profile Picture', style: TextStyle(fontFamily: "NexaBold")),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportswander/UI/profile_settings.dart';

class ProfileDrawer extends StatefulWidget {
  @override
  _ProfileDrawerState createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  late File _image = File('');
  final picker = ImagePicker();
  late String _uid;
  String _profileName = '';
  String _bio = '';
  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    loadProfileDetails();
  }

  Future<void> loadProfileDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userData')
          .doc(_uid)
          .get();
      setState(() {
        _profileName = snapshot['profileName'];
        _bio = snapshot['bio'];
        _profilePictureUrl = snapshot['profilePictureUrl'];
      });
    } catch (e) {
      print('Error loading profile details: $e');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // After setting the new image, update the profile picture in Firebase
        updateProfilePicture();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> updateProfilePicture() async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$_uid.jpg');
      UploadTask uploadTask = ref.putFile(_image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('userData').doc(_uid).update({
        'profilePictureUrl': imageUrl,
      });

      // After updating the profile picture in Firebase, reload the profile details
      loadProfileDetails();
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> confirmLogout() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(fontFamily: "MadimiOne"),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(fontFamily: "MadimiOne"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    fontFamily: "MadimiOne", color: Colors.orangeAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(
                    fontFamily: "MadimiOne", color: Colors.orangeAccent),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber[400],
            ),
            accountName: Text(
              _profileName,
              style: TextStyle(fontFamily: "MadimiOne", fontSize: 20),
            ),
            accountEmail: Text(
              _bio,
              style: TextStyle(fontFamily: "MadimiOne"),
            ),
            currentAccountPicture: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white, // Amber color circular avatar
                  backgroundImage: _profilePictureUrl.isNotEmpty
                      ? CachedNetworkImageProvider(_profilePictureUrl)
                      : AssetImage('assets/placeholder_image.png')
                          as ImageProvider<Object>,
                  radius: 80,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: getImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      radius: 14,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.zero,
          ),
          ListTile(
            leading: Icon(Icons.settings), // Icon for Profile Settings
            title: Text(
              'Profile Settings',
              style: TextStyle(fontFamily: "MadimiOne"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout), // Icon for Log Out
            title: Text(
              'Log Out',
              style: TextStyle(fontFamily: "MadimiOne"),
            ),
            onTap: confirmLogout,
          ),
        ],
      ),
    );
  }
}

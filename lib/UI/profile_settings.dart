import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';

class ProfileSettingsPage extends StatefulWidget {
  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late File _image = File(''); // Initialize _image with an empty file
  final picker = ImagePicker();

  late TextEditingController _profileNameController;
  late TextEditingController _bioController;

  late String _uid;
  List<String> sports = ['Football', 'Basketball', 'Tennis', 'Cricket'];
  List<String> selectedSports = [];
  String? _selectedCountry;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _profileNameController = TextEditingController();
    _bioController = TextEditingController();
    loadProfileDetails(); // Call loadProfileDetails() in initState()
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> loadProfileDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userData')
          .doc(_uid)
          .get();
      setState(() {
        _profileNameController = TextEditingController(
          text: snapshot['profileName'] ?? '',
        );
        _bioController = TextEditingController(
          text: snapshot['bio'] ?? '',
        );
        _selectedCountry = snapshot['selectedCountry'] ?? '';
        selectedSports = List<String>.from(snapshot['selectedSports'] ?? []);
        _profilePictureUrl = snapshot['profilePictureUrl'] ?? '';
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
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> updateProfile() async {
    try {
      if (_image.path.isNotEmpty) {
        // Upload image to Firebase Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('$_uid.jpg');
        UploadTask uploadTask = ref.putFile(_image);
        TaskSnapshot taskSnapshot = await uploadTask;
        _profilePictureUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('userData').doc(_uid).update({
        'profileName': _profileNameController.text,
        'bio': _bioController.text,
        'profilePictureUrl': _profilePictureUrl,
        'selectedSports': selectedSports,
        'selectedCountry': _selectedCountry,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 226, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 226, 226),
        title: Text(
          'Profile Settings',
          style: TextStyle(
            fontFamily: "MadimiOne",
            color: Colors.grey[800],
            fontSize: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile picture
              GestureDetector(
                onTap: getImage,
                child: Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade500,
                        backgroundImage: _profilePictureUrl != null
                            ? NetworkImage(_profilePictureUrl!)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 122,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.camera_alt,
                            size: 24, color: Colors.amber.shade500),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              // Profile name field
              TextFormField(
                controller: _profileNameController,
                cursorColor: const Color.fromARGB(255, 242, 96, 5),
                decoration: InputDecoration(
                  labelText: 'Profile Name',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 111, 110, 110),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 244, 160, 24),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 244, 160, 24),
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Color.fromARGB(255, 111, 110, 110),
                  fontFamily: "MadimiOne",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your profile name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              // Bio field
              TextFormField(
                controller: _bioController,
                cursorColor: const Color.fromARGB(255, 242, 96, 5),
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 111, 110, 110),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 244, 160, 24),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 244, 160, 24),
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Color.fromARGB(255, 111, 110, 110),
                  fontFamily: "MadimiOne",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              // Sports checkboxes
              Text(
                'Select Sports:',
                style: TextStyle(fontFamily: "MadimiOne"),
              ),
              SizedBox(height: 8.0),
              Wrap(
                children: sports.map((sport) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        activeColor: Color.fromARGB(255, 244, 160, 24),
                        value: selectedSports.contains(sport),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              selectedSports.add(sport);
                            } else {
                              selectedSports.remove(sport);
                            }
                          });
                        },
                      ),
                      Text(
                        sport,
                        style: TextStyle(fontFamily: "MadimiOne"),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),
              // Country dropdown
              Text(
                'Select Country:',
                style: TextStyle(fontFamily: "MadimiOne"),
              ),
              SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 244, 160, 24),
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: CountryCodePicker(
                  onChanged: (CountryCode countryCode) {
                    setState(() {
                      _selectedCountry = countryCode.name;
                    });
                  },
                  initialSelection: _selectedCountry ?? 'US',
                  showCountryOnly: true, // Show only country names
                  showOnlyCountryWhenClosed: true, // Hide dialing codes
                  alignLeft: true, // Align flag and country name left
                  favorite: [
                    'US',
                    'GB'
                  ], // Optional. Shows only country name and flag
                ),
              ),
              SizedBox(height: 20.0),
              // Update button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 244, 160, 24),
                ),
                onPressed: updateProfile,
                child: Text(
                  'Update Profile',
                  style:
                      TextStyle(fontFamily: "MadimiOne", color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

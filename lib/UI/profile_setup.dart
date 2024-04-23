import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:sportswander/UI/homepage.dart';

class ProfileSetupScreen extends StatefulWidget {
  final Function()? onTap;

  const ProfileSetupScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late File _image = File(''); // Initialize _image with an empty file
  final picker = ImagePicker();

  String _profileName = '';
  String _bio = '';
  late String _uid;
  List<String> sports = ['Football', 'Basketball', 'Tennis', 'Cricket'];
  List<String> selectedSports = [];
  String? _selectedCountry;
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
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

  Future<void> _register() async {
    try {
      // Set loading state to true
      setState(() {
        _isLoading = true;
      });

      // Upload image to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$_uid.jpg');
      UploadTask uploadTask = ref.putFile(_image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('userData').doc(_uid).set({
        'uid': _uid,
        'profileName': _profileName,
        'bio': _bio,
        'profilePictureUrl': imageUrl,
        'selectedSports': selectedSports,
        'selectedCountry': _selectedCountry,
      });

      // Set loading state to false
      setState(() {
        _isLoading = false;
      });

      // Navigate to the next screen or do whatever you want
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error registering user: $e');
      // Handle registration errors

      // Set loading state to false in case of error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 226, 226),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(80.0),
          child: Text(
            'Profile',
            style: TextStyle(
                fontSize: 30.0,
                fontFamily: 'MadimiOne',
                color: Color.fromARGB(255, 77, 73, 73)),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 232, 226, 226),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image selection widget
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade500,
                        backgroundImage:
                            _image != null ? FileImage(_image) : null,
                        child: _image == null || _image.path.isEmpty
                            ? Icon(Icons.account_circle,
                                size: 100, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(Icons.camera_alt,
                              size: 24, color: Colors.amber.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              // Profile name field
              TextFormField(
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
                style: TextStyle(color: Color.fromARGB(255, 111, 110, 110)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter your profile name'),
                      ),
                    );
                    return 'Please enter your profile name';
                  }
                  return null;
                },
                onChanged: (value) {
                  _profileName = value;
                },
              ),
              SizedBox(height: 20.0),
              // Bio field
              TextFormField(
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
                style: TextStyle(color: Color.fromARGB(255, 111, 110, 110)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter your bio'),
                      ),
                    );
                    return 'Please enter your bio';
                  }
                  return null;
                },
                onChanged: (value) {
                  _bio = value;
                },
              ),
              SizedBox(height: 20.0),
              // Sports checkboxes
              Text('Select Sports:'),
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
                      Text(sport),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),
              // Country dropdown
              Text('Select Country:'),
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
                  initialSelection: 'US',
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
              // Create button
              ArgonButton(
                height: 50,
                width: 100,
                borderRadius: 30.0,
                color: Color.fromARGB(255, 244, 160, 24),
                child: const Text(
                  "Create",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                loader: Container(
                  padding: const EdgeInsets.all(10),
                  color:
                      Color.fromARGB(255, 244, 160, 24), // Set color to amber
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                onTap: (startLoading, stopLoading, btnState) async {
                  if (_image.path.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a profile photo.'),
                      ),
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    // Call register method
                    startLoading(); // Start loading animation
                    await _register();
                    stopLoading(); // Stop loading animation
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:sportswander/UI/homepage.dart';
import 'package:sportswander/UI/verify_phone_number.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.onTap}) : super(key: key);

  final Future<void> Function() onTap;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String finalPhoneNum = '';
  bool agreedToTerms = false;

  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: '91',
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India',
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  Future<void> signInWithPhoneNumber() async {
    setState(() {
      isLoading = true;
    });

    try {
      finalPhoneNum = '+${selectedCountry.phoneCode}${phoneController.text}';
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: finalPhoneNum,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle verification failure
          print('Verification Failed: ${e.message}');
          // Show relevant error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification Failed: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                verificationId: verificationId,
                phoneNumber: finalPhoneNum,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code Auto Retrieval Timeout: $verificationId');
        },
      );
    } catch (e) {
      print('Error signing in with phone number: $e');
      // Show relevant error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length),
    );

    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 70,
            ),
            Image.asset(
              'assets/logo.png',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 5,
            ),
            // Description for the app
            Text(
              'Welcome to SportsWander!',
              style: const TextStyle(
                  fontFamily: 'MadimiOne',
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 77, 73, 73)),
              textAlign: TextAlign.center,
            ),
            Text(
              'Enter your phone number to get started.',
              style: TextStyle(
                fontFamily: 'MadimiOne',
                color: Color.fromARGB(255, 111, 110, 110),
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: phoneController,
              onChanged: (value) {
                setState(() {});
              },
              cursorColor: const Color.fromARGB(255, 242, 96, 5),
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12.5),
                  child: InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        countryListTheme: const CountryListThemeData(
                          bottomSheetHeight: 600,
                        ),
                        onSelect: (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        },
                      );
                    },
                    child: Text(
                      "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 77, 73, 73),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                suffixIcon: phoneController.text.length > 8
                    ? Container(
                        margin: const EdgeInsets.all(10.0),
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 244, 160, 24),
                        ),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    : null,
                labelText: 'Phone Number',
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                  color: Color.fromARGB(255, 111, 110, 110),
                ),
                hintText: 'Enter your phone number',
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                  color: Colors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 242, 96, 5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 244, 160, 24),
                  ),
                ),
              ),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 77, 73, 73),
              ),
            ),
            const SizedBox(height: 20.0),
            // Terms and Conditions Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Checkbox(
                  activeColor: Color.fromARGB(255, 244, 160, 24),
                  value: agreedToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      agreedToTerms = value ?? false;
                    });
                  },
                ),
                Text(
                  'I agree to the ',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to your privacy policy page
                    // Implement this as per your app's structure
                  },
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            // Login Button
            ArgonButton(
              height: 50,
              width: 100,
              borderRadius: 30.0,
              color: Color.fromARGB(255, 244, 160, 24),
              child: const Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              loader: Container(
                color: Colors.amber,
                padding: const EdgeInsets.all(10),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              onTap: (startLoading, stopLoading, btnState) async {
                if (phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text(
                          'Please enter your phone number.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      backgroundColor: Color.fromARGB(255, 244, 160, 24),
                    ),
                  );
                  return;
                }

                if (!agreedToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text(
                          'Please agree to the terms and conditions.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      backgroundColor: Color.fromARGB(255, 244, 160, 24),
                    ),
                  );
                  return;
                }

                try {
                  startLoading();

                  await signInWithPhoneNumber();
                } catch (error) {
                  // Handle any errors here, such as displaying an error message to the user
                  print('Error: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text(
                          'Error: $error',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      backgroundColor: Color.fromARGB(255, 244, 160, 24),
                    ),
                  );
                } finally {
                  stopLoading();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

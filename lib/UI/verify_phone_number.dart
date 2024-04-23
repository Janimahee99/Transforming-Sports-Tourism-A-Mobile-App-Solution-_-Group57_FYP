import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sportswander/UI/homepage.dart';
import 'package:sportswander/UI/profile_setup.dart';

class VerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool isLoading = false;
  TextEditingController _verificationCodeController = TextEditingController();

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitVerificationCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _verificationCodeController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
                  onTap: () {},
                )),
      );
    } catch (error) {
      // Handle verification error
      print('Error verifying phone number: $error');
      // You can display an error message to the user here
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    try {
      // Validate phone number
      if (widget.phoneNumber.isEmpty) {
        print('Phone number is empty.');
        return;
      }

      // Ensure phone number is in E.164 format
      String formattedPhoneNumber = '+${widget.phoneNumber}';
      print(formattedPhoneNumber);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Sign in with the auto-generated credential
          await FirebaseAuth.instance.signInWithCredential(credential);
          // Navigate to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle verification failure
          print('Verification Failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // OTP Resent successfully, you can notify the user if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP Resent successfully'),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
          print('Code Auto Retrieval Timeout: $verificationId');
        },
      );
    } catch (error) {
      print('Error resending OTP: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 226, 226),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(55.0),
          child: Text(
            'Verification',
            style: TextStyle(
                fontSize: 30.0,
                fontFamily: 'MadimiOne',
                color: Color.fromARGB(255, 77, 73, 73)),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 232, 226, 226),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the OTP sent to ',
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 111, 110, 110)),
              ),
              Text(
                '${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 111, 110, 110),
                ),
              ),
              Image.asset(
                'assets/verification.png',
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
              PinCodeTextField(
                cursorColor: Color.fromARGB(255, 248, 189, 93),
                appContext: context,
                length: 6,
                onChanged: (value) {},
                pinTheme: PinTheme(
                  inactiveColor: Colors.grey.shade400,
                  selectedColor: Color.fromARGB(255, 245, 177, 69),
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.green,
                ),
                controller: _verificationCodeController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 244, 160, 24),
                ),
                onPressed: isLoading ? null : _submitVerificationCode,
                child: Text('Submit',
                    style: TextStyle(color: Colors.white, fontSize: 18.0)),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 244, 160, 24),
                ),
                onPressed: isLoading ? null : _resendOTP,
                child: Text('Resend OTP',
                    style: TextStyle(color: Colors.white, fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

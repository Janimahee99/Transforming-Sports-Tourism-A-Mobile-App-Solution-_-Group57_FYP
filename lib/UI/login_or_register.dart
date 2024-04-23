import 'package:flutter/material.dart';
import 'package:sportswander/UI/login.dart';
import 'package:sportswander/UI/profile_setup.dart';
import 'package:sportswander/UI/registration.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginOrRegisterPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(
        onTap: () async {
          togglePages();
        },
      );
    } else {
      return ProfileSetupScreen(
        onTap: togglePages,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:zaizen/pages/login.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(startOnSignUp: true);
  }
}

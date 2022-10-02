import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/pages/loading_widget.dart';
import 'package:infans_phone/pages/login_screen.dart';

import 'infansphone_home.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: FirebaseAuth.instance.authStateChanges().first, builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
      if(snapshot.hasData) {
        return snapshot.data != null ? const InfansPhoneAppHome() : const LoginScreen();
      } else {
        return const LoadingWidget();
      }
    });
  }
}

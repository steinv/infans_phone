import 'package:flutter/material.dart';
import 'package:infans_phone/models/user_secure_storage.dart';
import 'package:infans_phone/pages/login_screen.dart';

import 'infansphone_home.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: UserSecureStorage.isAuthenticated(),
        builder:
            (BuildContext context, AsyncSnapshot<bool> authenticated) =>
                true == authenticated.data
                    ? const InfansPhoneAppHome()
                    : const LoginScreen()
    );
  }
}

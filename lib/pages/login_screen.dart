import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../infansphone_home.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<String?> _authUser(LoginData data) {
    debugPrint('Email: ${data.name}, Password: ${data.password}');
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: data.name, password: data.password)
        .then((_) => null, onError: (error) => error.toString());
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Email: $name');
    return FirebaseAuth.instance.sendPasswordResetEmail(email: name).then((r) => 'Check uw e-mail');
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Infans',
      logo: const AssetImage('assets/images/infans.png'),
      messages: LoginMessages(
        userHint: 'E-mail',
        passwordHint: 'Wachtwoord',
        loginButton: 'Aanmelden',
        forgotPasswordButton: 'Wachtwoord vergeten',
        recoverPasswordButton: 'Wachtwoord herstellen',
        goBackButton: 'Terug',
        confirmPasswordError: 'Wachtwoord foutief',
        recoverPasswordDescription: 'Password herstellen',
        recoverPasswordSuccess: 'Check uw email',
      ),
      onLogin: _authUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const InfansPhoneAppHome(),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}

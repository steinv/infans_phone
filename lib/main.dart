import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/auth.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // var dataSnapshot = await FirebaseDatabase.instance.ref('scheduled').get();
  // dataSnapshot.children.forEach((element) { print('${element.value}'); });

  // FirebaseDatabase.instance.useDatabaseEmulator(emulatorHost, emulatorPort);
  runApp(const InfansPhoneApp());
}

class InfansPhoneApp extends StatelessWidget {
  const InfansPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      title: "Infans Phone",
      /**theme: ThemeData(
          colorSchemeSeed: const Color(0xffd12da7),
          brightness: Brightness.light,
          useMaterial3: true,
          ),*/
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: const Color(0xffd12da7),
          secondary: const Color(0x98ffb7e2),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWidget(),
    );
  }
}

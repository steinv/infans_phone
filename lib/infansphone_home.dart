import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/pages/call_screen.dart';
import 'package:infans_phone/pages/chat_screen.dart';
import 'package:infans_phone/pages/contact_screen.dart';
import 'package:infans_phone/pages/input_phonenumber_screen.dart';
import 'package:twilio_voice_mimp/twilio_voice.dart';

class InfansPhoneAppHome extends StatefulWidget {
  const InfansPhoneAppHome({super.key});

  @override
  InfansPhoneAppHomeState createState() => InfansPhoneAppHomeState();
}

class InfansPhoneAppHomeState extends State<InfansPhoneAppHome> with SingleTickerProviderStateMixin {
  static const tabs = <Widget>[
    Tab(text: "CHATS"),
    Tab(text: "CALLS"),
    Tab(text: "CONTACTS"),
  ];

  late TabController _tabController;
  bool showFab = true;

  @override
  void initState() {
    super.initState();
    TwilioVoice.instance.setDefaultCallerName('Infans');
    TwilioVoice.instance.setOnDeviceTokenChanged((token) {
      registerTwilio();
    });
    registerTwilio();

    _tabController = TabController(vsync: this, initialIndex: 0, length: tabs.length);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });

  }

  registerTwilio() async {
    final result = await FirebaseFunctions.instance.httpsCallable("twilioAccessToken").call();
    final String? androidNotificationToken = !kIsWeb && Platform.isAndroid ? await FirebaseMessaging.instance.getToken() : null;
    TwilioVoice.instance.setTokens(accessToken: result.data['token'], deviceToken: androidNotificationToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Infans Phone"),
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          ChatScreen(),
          CallsScreen(),
          ContactScreen(),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .secondary,
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
        onPressed: () =>
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InputPhoneNumberScreen()),
      ),
    ): null
    ,
    );
  }
}

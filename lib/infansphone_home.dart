import 'package:flutter/material.dart';
import 'package:infans_phone/models/chat_model.dart';
import 'package:infans_phone/pages/call_screen.dart';
import 'package:infans_phone/pages/chat_screen.dart';
import 'package:infans_phone/pages/chat_with_screen.dart';
import 'package:infans_phone/pages/contact_screen.dart';

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
         // TODO phoneNumber input
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatWithScreen(ChatModel('TODO Input phoneNumber screen', List.empty()))),
      ),
    ): null
    ,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:infans_phone/pages/call_screen.dart';
import 'package:infans_phone/pages/chat_screen.dart';
import 'package:infans_phone/pages/contact_screen.dart';

class InfansPhoneAppHome extends StatefulWidget {
  const InfansPhoneAppHome({super.key});

  @override
  _InfansPhoneAppHomeState createState() => _InfansPhoneAppHomeState();
}

class _InfansPhoneAppHomeState extends State<InfansPhoneAppHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showFab = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, initialIndex: 0, length: 3);
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
        title: Text("Infans Phone"),
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const <Widget>[
            Tab(text: "CHATS"),
            Tab(text: "CALLS"),
            Tab(text: "CONTACTS"),
          ],
        ),
        /*actions: const <Widget>[
          Icon(Icons.search),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
          ),
          Icon(Icons.more_vert)
        ],*/
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ChatScreen(),
          CallsScreen(),
          ContactScreen(),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: () => print("open chats"),
            )
          : null,
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/call_model.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CallsScreenState();
  }
}

class CallsScreenState extends State<CallsScreen> {
  List<CallModel> calls = List.empty();

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance.ref('calls').onValue.listen((event) {
      print(event.snapshot.value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Calls",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

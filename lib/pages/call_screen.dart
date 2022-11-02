import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/models/user_model.dart';
import 'package:infans_phone/pages/calling_screen.dart';
import 'package:infans_phone/util/formatter.dart';

import '../models/call_model.dart';
import '../util/firebase_users.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CallsScreenState();
  }
}

class CallsScreenState extends State<CallsScreen> {
  late StreamSubscription<DatabaseEvent> callSubscription;
  List<CallModel> calls = List.empty();
  List<UserModel> users = List.empty();

  @override
  void initState() {
    super.initState();

    callSubscription = FirebaseDatabase.instance.ref('calls').onValue.listen((event) {
      final data = event.snapshot.value as Map;
      List<CallModel> callsSorted = data.entries.map((entry) => CallModel.fromJson(entry.key, entry.value)).toList().cast<CallModel>();
      callsSorted.sort((x, y) => y.timestamp - x.timestamp);

      setState(() {
        calls = callsSorted;
      });
    });

    FirebaseUsers.instance.usersStream.listen((event) {
      setState(() {
        users = event;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    callSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff2f2f2),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: calls.map((call) {
                var currentUser = FirebaseUsers.getUserByPhoneNumber(users, call.phoneNumber);
                var displayName = currentUser != null ? currentUser.getFullName() : call.phoneNumber;
                return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: getCallIcon(call),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          FormatterUtil.timeStampAsString(call.timestamp, null),
                          style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                        ),
                      ],
                    ),
                    subtitle: Text(FormatterUtil.timeAsString(call.dialCallDuration)),
                    onTap: () => CallingScreen.dialCustomer(call.phoneNumber).then((dialed) => dialed == true
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CallingScreen(caller: displayName)),
                          )
                        : null));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Icon getCallIcon(CallModel callModel) {
    switch (callModel.type) {
      case 'inbound':
        {
          return callModel.dialCallDuration < 1 ? const Icon(Icons.call_missed, color: Colors.red) : const Icon(Icons.call_received);
        }
      case 'outbound':
        {
          return callModel.dialCallDuration < 1 ? const Icon(Icons.call_missed_outgoing, color: Colors.red) : const Icon(Icons.call_made);
        }
      default:
        return const Icon(Icons.call_end);
    }
  }
}

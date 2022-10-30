import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/pages/calling_screen.dart';
import 'package:infans_phone/util/formatter.dart';
import 'package:twilio_voice/twilio_voice.dart';

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
      final data = event.snapshot.value as Map;
      List<CallModel> callsSorted = data.entries.map((entry) => CallModel.fromJson(entry.key, entry.value)).toList().cast<CallModel>();
      callsSorted.sort((x, y) => y.timestamp - x.timestamp);

      setState(() {
        calls = callsSorted;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff2f2f2),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: calls
                  .map((call) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: getCallIcon(call),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            call.phoneNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            FormatterUtil.timeStampAsString(call.timestamp, null),
                            style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                          ),
                        ],
                      ),
                      subtitle: Text(FormatterUtil.timeAsString(call.dialCallDuration)),
                      onTap: () => dialCustomer(call.phoneNumber).then((dialed) => dialed == true
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CallingScreen()),
                            )
                          : null)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> dialCustomer(String phoneNumber) async {
    String tel = FormatterUtil.phoneNumberToIntlFormat(phoneNumber);
    return TwilioVoice.instance.hasMicAccess().then((hasMicAccess) {
      if (!hasMicAccess) {
        TwilioVoice.instance.requestMicAccess().then((value) {
          if (true == value) {
            return TwilioVoice.instance.call.place(to: tel, from: '+32460230233');
          }
          return false;
        });
      }
      return TwilioVoice.instance.call.place(to: tel, from: '+32460230233');
    });
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

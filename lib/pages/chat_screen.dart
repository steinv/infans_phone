import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/models/message_model.dart';
import '../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  List<ChatModel> chats = List.empty();

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance.ref('messages').onValue.listen((event) {
      // { phoneNumber: { "key": { object }}}
      final data = jsonDecode(jsonEncode(event.snapshot.value));
      List<ChatModel> chatsSorted = data.entries
          .map((entry) {
            List<MessageModel> messages =
                entry.value.entries.map((msg) => MessageModel.fromJson(msg.key as String, msg.value)).toList().cast<MessageModel>();
            messages.sort((msg1, msg2) => msg2.timestamp - msg1.timestamp);
            return ChatModel(entry.key, messages);
          })
          .toList()
          .cast<ChatModel>();
      chatsSorted.sort((x, y) => y.messages[0].timestamp - x.messages[0].timestamp);

      setState(() {
        chats = chatsSorted;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: chats
            .map(
              (chat) => Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey,
                      backgroundImage: const AssetImage('assets/images/default-user.png'),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          chat.phoneNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          chat.messages[0].timeStampAsString(null),
                          style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                        ),
                      ],
                    ),
                    subtitle: Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        chat.messages[0].body,
                        style: const TextStyle(color: Colors.grey, fontSize: 15.0),
                      ),
                    ),
                    onTap: () => Navigator.push(
                        context,
                        // using index i open a chat widget
                        MaterialPageRoute(builder: (context) => const MaterialApp())),
                  ),
                  const Divider(
                    height: 10.0,
                  ),
                ],
              ),
            )
            .toList());
  }
}

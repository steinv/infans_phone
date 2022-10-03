import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infans_phone/util/formatter.dart';
import 'package:infans_phone/util/messages_repository.dart';
import '../models/chat_model.dart';
import 'chat_with_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  late StreamSubscription listen;
  List<ChatModel> chats = List.empty();

  @override
  void initState() {
    super.initState();
    listen = MessagesRepository.listen((chatsSorted) => setState(() => chats = chatsSorted));
  }

  @override
  void dispose() {
    super.dispose();
    listen.cancel();
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
                          FormatterUtil.timeStampAsString(chat.messages[0].timestamp, null),
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
                        MaterialPageRoute(builder: (context) => ChatWithScreen(chat))),
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

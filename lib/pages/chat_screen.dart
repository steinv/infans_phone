import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/models/message_model.dart';
import 'package:infans_phone/pages/received_message_screen.dart';
import 'package:infans_phone/pages/sent_message_screen.dart';
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

class ChatWithScreen extends StatefulWidget {
  final ChatModel chatModel;

  const ChatWithScreen(this.chatModel, {super.key});

  @override
  State<StatefulWidget> createState() => ChatWithScreenState();
}

class ChatWithScreenState extends State<ChatWithScreen> {
  final _newReplyController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          const CircleAvatar(backgroundImage: AssetImage('assets/images/default-user.png')),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
          Text(widget.chatModel.phoneNumber),
        ]),
        actions: const <Widget>[
          Icon(Icons.call),
          Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
          Icon(Icons.search),
          Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
          Icon(Icons.more_vert)
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/bg_chat.jpg"), fit: BoxFit.cover)),
        child: ListView(
            children: widget.chatModel.messages.reversed
                .map((element) => element.from == '+32460230233' ? SentMessageScreen(element.body) : ReceivedMessageScreen(element.body))
                .toList()),
      ),
      bottomSheet: TextField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Bericht',
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              print(_newReplyController.text);
              _newReplyController.clear();
            },
          ),
        ),
        autofocus: true,
        // focusNode: _focusnode,
        minLines: 1,
        maxLines: 3,
        controller: _newReplyController,
        keyboardType: TextInputType.text,
      ),
    );
  }
}

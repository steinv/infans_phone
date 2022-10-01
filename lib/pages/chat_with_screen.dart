import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/pages/received_message_screen.dart';
import 'package:infans_phone/pages/sent_message_screen.dart';
import '../models/chat_model.dart';

class ChatWithScreen extends StatefulWidget {
  final ChatModel chatModel;

  const ChatWithScreen(this.chatModel, {super.key});

  @override
  State<StatefulWidget> createState() => ChatWithScreenState();
}

class ChatWithScreenState extends State<ChatWithScreen> {
  final _newReplyController = TextEditingController();

  late ChatModel chat = widget.chatModel;

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref('messages/${chat.phoneNumber}').onValue.listen((event) {
        return;
    });
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
      bottomNavigationBar: TextField(
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

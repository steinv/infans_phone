import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/pages/received_message_screen.dart';
import 'package:infans_phone/pages/sent_message_screen.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

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
      if(event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        print(data);
        List<MessageModel> messages = data.entries.map((msg) => MessageModel.fromJson(msg.key as String, msg.value)).toList().cast<MessageModel>();
        messages.sort((msg1, msg2) => msg2.timestamp - msg1.timestamp);
        var updatedChatModel = ChatModel(chat.phoneNumber, messages);

        setState(() {
          chat = updatedChatModel;
          print(chat);
        });
      }
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
          Text(chat.phoneNumber),
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                  children: chat.messages.reversed
                      .map((element) => element.from == '+32460230233' ? SentMessageScreen(element.body) : ReceivedMessageScreen(element.body))
                      .toList()),
            ),
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
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
          ],
        ),
      ),
    );
  }
}

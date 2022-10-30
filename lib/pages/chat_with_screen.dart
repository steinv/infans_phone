import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/pages/received_message_screen.dart';
import 'package:infans_phone/pages/sent_message_screen.dart';
import 'package:twilio_voice/twilio_voice.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../util/formatter.dart';
import '../util/messages_repository.dart';
import 'calling_screen.dart';

class ChatWithScreen extends StatefulWidget {
  final ChatModel chatModel;

  const ChatWithScreen(this.chatModel, {super.key});

  @override
  State<StatefulWidget> createState() => ChatWithScreenState();
}

class ChatWithScreenState extends State<ChatWithScreen> {
  final _newReplyController = TextEditingController();
  late ChatModel chat = widget.chatModel;
  late StreamSubscription listen;

  @override
  void initState() {
    super.initState();
    listen = MessagesRepository.listenForPhoneNumber(chat.phoneNumber, (chatSorted) => setState(() => chat = chatSorted));
  }

  @override
  void dispose() {
    super.dispose();
    listen.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(children: <Widget>[
          const CircleAvatar(backgroundImage: AssetImage('assets/images/default-user.png')),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
          Text(chat.phoneNumber),
        ]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => dialCustomer(chat.phoneNumber).then((dialed) => dialed == true
                ? Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CallingScreen()),
                  )
                : null),
          ),
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
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView(
                    reverse: true,
                    shrinkWrap: true,
                    children: chat.messages
                        .map((element) => element.from == '+32460230233' ? SentMessageScreen(element.body) : ReceivedMessageScreen(element.body))
                        .toList()),
              ),
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
                    var addressee = chat.phoneNumber;
                    var textToSend = _newReplyController.text;

                    // immediately show the result even before the DB persisted and processed the message
                    setState(() => chat.messages.insert(0, MessageModel("dummy", textToSend, "+32460230233", addressee, DateTime.now().millisecond)));

                    FirebaseFunctions.instance.httpsCallable('sendSms').call({'to': addressee, 'message': textToSend}).catchError((error) {
                      debugPrint(error);
                      setState(() => chat.messages.removeAt(0));
                    });

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

  // TODO refactor duplicated code
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
}

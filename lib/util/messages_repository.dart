import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:infans_phone/util/formatter.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class MessagesRepository {
  static StreamSubscription<DatabaseEvent> listen(void Function(List<ChatModel>) onEvent) {
    return FirebaseDatabase.instance.ref('messages').onValue.listen((event) {
      final data = event.snapshot.value as Map;
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
      onEvent(chatsSorted);
    });
  }

  static StreamSubscription<DatabaseEvent> listenForPhoneNumber(String telephoneNumber, void Function(ChatModel) onEvent) {
    var phoneNumber = FormatterUtil.phoneNumberToIntlFormat(telephoneNumber);
    return FirebaseDatabase.instance.ref('messages/$phoneNumber').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        List<MessageModel> messages = data.entries.map((msg) => MessageModel.fromJson(msg.key as String, msg.value)).toList().cast<MessageModel>();
        messages.sort((msg1, msg2) => msg2.timestamp - msg1.timestamp);
        onEvent(ChatModel(phoneNumber, messages));
      }
    });
  }
}

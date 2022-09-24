import 'message_model.dart';

class ChatModel {
  final String phoneNumber;
  final List<MessageModel> messages;

  ChatModel(this.phoneNumber, this.messages);
}

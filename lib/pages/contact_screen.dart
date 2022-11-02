
import 'package:flutter/material.dart';
import 'package:infans_phone/models/chat_model.dart';
import 'package:infans_phone/util/formatter.dart';

import '../models/user_model.dart';
import '../util/firebase_users.dart';
import 'chat_with_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ContactScreenState();
  }
}

class ContactScreenState extends State<ContactScreen> {
  List<UserModel> contacts = List.empty();

  @override
  void initState() {
    super.initState();

    FirebaseUsers.instance.usersStream.listen((event) {
      setState(() => contacts = event);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: contacts
                .map((contact) => ListTile(
                      leading: CircleAvatar(
                        foregroundColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey,
                        backgroundImage: contact.profilePicture(),
                      ),
                      title: Text(
                        contact.getFullName(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(contact.email ?? ""),
                      onTap: onTapContact(contact),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  onTapContact(UserModel contact) {
    if (contact.phoneNumber != null) {
      String phoneNumber = FormatterUtil.phoneNumberToIntlFormat(contact.phoneNumber!);
      var chat = ChatModel(phoneNumber, List.empty());
      return () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatWithScreen(chatModel: chat, userModel: contact)));
    } else {
      return () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Chatten'),
              content: Text('${contact.getFullName()} heeft geen telefoonnummer geregistreerd'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
    }
  }
}

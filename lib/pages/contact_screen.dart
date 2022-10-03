import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/models/chat_model.dart';
import 'package:infans_phone/util/formatter.dart';

import '../models/user_model.dart';
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

    FirebaseDatabase.instance.ref('users').onValue.listen((event) {
      // TODO why is jsonDecode(jsonEncode necessary here?
      final data = jsonDecode(jsonEncode(event.snapshot.value));
      List<UserModel> usersWithName =
          data.entries.map((entry) => UserModel.fromJson(entry.key, entry.value)).where((element) => element.name != null).toList().cast<UserModel>();
      usersWithName.sort((x, y) => x.getFullName().compareTo(y.getFullName()));

      setState(() {
        contacts = usersWithName;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
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
          ),
        ],
      ),
    );
  }

  onTapContact(UserModel contact) {
    if (contact.phoneNumber != null) {
      String phoneNumber = FormatterUtil.phoneNumberToIntlFormat(contact.phoneNumber!);
      return () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatWithScreen(ChatModel(phoneNumber, List.empty()))));
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

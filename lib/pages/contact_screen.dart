import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

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
      // TODO figure out a way that's less heavy than jsonDecode(jsonEncode()) to convert
      final data = jsonDecode(jsonEncode(event.snapshot.value));
      List<UserModel> usersWithName = data.entries
          .map((entry) => UserModel.fromJson(entry.key, entry.value))
          .where((element) => element.name != null)
          .toList()
          .cast<UserModel>();
      usersWithName.sort((x, y) => x.getFullName().compareTo(y.getFullName()));

      setState(() {
        contacts = usersWithName;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff2f2f2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: ListView(
                children: contacts.map((contact) => ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: contact.profilePicture(),
                          ),
                          title: Text(
                            contact.getFullName(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(contact.email ?? ""),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MaterialApp()),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

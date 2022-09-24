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
  Iterable<UserModel> contacts = List.empty();

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance.ref('users').orderByChild('name').onValue.listen((event) {
      final data = event.snapshot.value as Map<String, dynamic>;
      var usersWithName = data.entries
          .map((entry) => UserModel.fromJson(entry.key, entry.value as Map<String, dynamic>))
          .where((element) => element.name != null);
          // .sort((x, y) => Intl.Collator().compare(x.name + x.surname, y.name + y.surname)))

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
                            backgroundImage: profilePicture(contact.photoURL),
                          ),
                          title: Text(
                            '${contact.name!} ${contact.surname?? ""}',
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

  ImageProvider profilePicture(String? photoURL) {
    if (photoURL == null || photoURL.isEmpty) {
      return const AssetImage('images/default-user.png');
    } else {
      return NetworkImage(photoURL);
    }
  }
}

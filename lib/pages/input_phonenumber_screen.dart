import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:infans_phone/pages/loading_widget.dart';

import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../util/formatter.dart';
import 'chat_with_screen.dart';

class InputPhoneNumberScreen extends StatelessWidget {
  const InputPhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: contacts(),
        builder: (BuildContext context, AsyncSnapshot<List<UserModel>> contactsSnapshot) {
          if (contactsSnapshot.hasData) {
            var contacts = contactsSnapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Telefoonnummer'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Autocomplete<UserModel>(
                  optionsBuilder: (TextEditingValue textEditingValue) => contacts
                      .where((user) => FormatterUtil.phoneNumberToIntlFormat(user.phoneNumber!)
                          .startsWith(FormatterUtil.phoneNumberToIntlFormat(textEditingValue.text)))
                      .toList(),
                  displayStringForOption: (UserModel user) => user.phoneNumber!,
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) =>
                      TextField(
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (fieldTextEditingController.text.trim().isNotEmpty) {
                            var phoneNumber = FormatterUtil.phoneNumberToIntlFormat(fieldTextEditingController.text);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatWithScreen(ChatModel(phoneNumber, List.empty()))));
                          }
                        },
                      ),
                    ),
                  ),
                  onSelected: (UserModel selection) {
                    var phoneNumber = FormatterUtil.phoneNumberToIntlFormat(selection.phoneNumber!);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatWithScreen(ChatModel(phoneNumber, List.empty()))));
                  },
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<UserModel> onSelected, Iterable<UserModel> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 30.0, bottom: 15.0),
                          child: Container(
                            color: const Color(0x98ffb7e2),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(10.0),
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final UserModel option = options.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: ListTile(
                                    title: Text(option.getFullName()),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return const LoadingWidget();
          }
        });
  }

  Future<List<UserModel>> contacts() {
    return FirebaseDatabase.instance.ref('users').get().then((event) {
      if (event.value == null) {
        return List.empty();
      }
      final data = jsonDecode(jsonEncode(event.value)) as Map;
      List<UserModel> usersWithPhoneNumber = data.entries
          .map((entry) => UserModel.fromJson(entry.key, entry.value))
          .where((element) => element.phoneNumber != null && (element.name != null || element.surname != null))
          .toList()
          .cast<UserModel>();
      usersWithPhoneNumber.sort((x, y) => x.getFullName().compareTo(y.getFullName()));
      return usersWithPhoneNumber;
    });
  }
}

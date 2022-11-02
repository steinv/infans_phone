import 'package:flutter/material.dart';
import 'package:infans_phone/pages/loading_widget.dart';

import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../util/firebase_users.dart';
import '../util/formatter.dart';
import 'calling_screen.dart';
import 'chat_with_screen.dart';

enum DialAction {
  chat,
  call,
}

class InputPhoneNumberScreen extends StatelessWidget {
  final DialAction action;
  const InputPhoneNumberScreen({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseUsers.instance.usersStream.first.then((users) => users.where((user) => user.phoneNumber != null).toList()),
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
                            performAction(context, fieldTextEditingController.text, contacts);
                          }
                        },
                      ),
                    ),
                  ),
                  onSelected: (UserModel selection) => performAction(context, selection.phoneNumber!, contacts),
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<UserModel> onSelected, Iterable<UserModel> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 30.0, bottom: 15.0),
                          child: Container(
                            color: const Color(0x98f3f3f3),
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

  performAction(BuildContext context, String tel, List<UserModel> contacts) {
    var phoneNumber = FormatterUtil.phoneNumberToIntlFormat(tel);
    var user = FirebaseUsers.getUserByPhoneNumber(contacts, phoneNumber);

    switch (action) {
      case DialAction.call: {
        var displayName = user != null ? user.getFullName() : phoneNumber;
        return CallingScreen.dialCustomer(phoneNumber).then(
                (dialed) => dialed == true ? Navigator.push(context, MaterialPageRoute(builder: (context) => CallingScreen(caller: displayName))) : null
        );
      }
      case DialAction.chat: {
        var chat = ChatModel(phoneNumber, List.empty());
        return Navigator.push(context, MaterialPageRoute(builder: (context) => ChatWithScreen(chatModel: chat, userModel: user)));
      }
    }

  }
}

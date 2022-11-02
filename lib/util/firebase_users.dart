import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:infans_phone/util/formatter.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user_model.dart';

class FirebaseUsers {
  static final FirebaseUsers _instance = FirebaseUsers._();
  static FirebaseUsers get instance => _instance;

  late final ValueStream<List<UserModel>> usersStream;

  FirebaseUsers._() {
    usersStream = ValueConnectableStream(
        FirebaseDatabase.instance.ref('users').onValue
            .map((event) => _mapDatabaseEventToUsersList(event))
    ).autoConnect();
  }

  List<UserModel> _mapDatabaseEventToUsersList(DatabaseEvent event) {
    // TODO why is jsonDecode/jsonEncode necessary here?
    final data = jsonDecode(jsonEncode(event.snapshot.value));
    List<UserModel> usersWithName =
        data.entries.map((entry) => UserModel.fromJson(entry.key, entry.value)).where((element) => element.name != null).toList().cast<UserModel>();
    usersWithName.sort((x, y) => x.getFullName().compareTo(y.getFullName()));

    return usersWithName;
  }

  static UserModel? getUserByPhoneNumber(List<UserModel>? users, String phoneNumber) {
    if (users != null) {
      var usersWithPhoneNumber =
          users.where((element) => FormatterUtil.phoneNumberToIntlFormat(phoneNumber) == FormatterUtil.phoneNumberToIntlFormat(element.phoneNumber));
      return usersWithPhoneNumber.isNotEmpty ? usersWithPhoneNumber.first : null;
    }
    return null;
  }
}

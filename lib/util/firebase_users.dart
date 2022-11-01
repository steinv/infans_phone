import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:infans_phone/util/formatter.dart';

import '../models/user_model.dart';

class FirebaseUsers {
  static final FirebaseUsers _instance = FirebaseUsers._();
  static FirebaseUsers get instance => _instance;

  late final Stream<List<UserModel>> usersStream;
  List<UserModel>? users;

  FirebaseUsers._() {
    usersStream = FirebaseDatabase.instance.ref('users').onValue.map((event) => _mapDatabaseEventToUsersList(event));
    FirebaseDatabase.instance.ref('users').onValue.first.then((event) => users = _mapDatabaseEventToUsersList(event));
  }

  List<UserModel> _mapDatabaseEventToUsersList(DatabaseEvent event) {
    // TODO why is jsonDecode(jsonEncode necessary here?
    final data = jsonDecode(jsonEncode(event.snapshot.value));
    List<UserModel> usersWithName =
        data.entries.map((entry) => UserModel.fromJson(entry.key, entry.value)).where((element) => element.name != null).toList().cast<UserModel>();
    usersWithName.sort((x, y) => x.getFullName().compareTo(y.getFullName()));

    users = usersWithName;
    return usersWithName;
  }

  String getNameByPhoneNumber(String phoneNumber) {
    // https://stackoverflow.com/questions/38933801/calling-an-async-method-from-component-constructor-in-dart
    if (users != null) {
      var usersWithPhoneNumber = users!
          .where((element) => FormatterUtil.phoneNumberToIntlFormat(phoneNumber) == FormatterUtil.phoneNumberToIntlFormat(element!.phoneNumber));
      return usersWithPhoneNumber.isNotEmpty ? usersWithPhoneNumber.first.getFullName() : phoneNumber;
    }
    return phoneNumber;
  }
}

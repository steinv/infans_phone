import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const String secureStorageKeyAuthenticated = 'infans_phone_authenticated';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> isAuthenticated() {
    return _storage
        .read(key: secureStorageKeyAuthenticated)
        .then((value) => value != null);
  }

  static Future<void> setAuthenticated(String? value) {
    return _storage
        .write(key: secureStorageKeyAuthenticated, value: value);
  }
}
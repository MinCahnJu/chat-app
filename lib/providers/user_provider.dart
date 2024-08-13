import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final String user_id;
  final String user_pw;
  final String name;
  final String phone;

  User(
      {required this.user_id,
      required this.user_pw,
      required this.name,
      required this.phone});
}

class UserProvider with ChangeNotifier {
  User? _user;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    _saveUserToStorage(user);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _storage.deleteAll();
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final userId = await _storage.read(key: 'user_id');
    final userPw = await _storage.read(key: 'user_pw');
    final name = await _storage.read(key: 'name');
    final phone = await _storage.read(key: 'phone');
    if (userId != null && userPw != null && name != null && phone != null) {
      _user = User(
        user_id: userId,
        user_pw: userPw,
        name: name,
        phone: phone,
      );
      notifyListeners();
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    await _storage.write(key: 'user_id', value: user.user_id);
    await _storage.write(key: 'user_pw', value: user.user_pw);
    await _storage.write(key: 'name', value: user.name);
    await _storage.write(key: 'phone', value: user.phone);
  }
}

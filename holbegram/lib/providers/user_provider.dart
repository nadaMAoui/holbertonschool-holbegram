import 'package:flutter/foundation.dart';
import 'package:holbegram/methods/auth_methods.dart';
import 'package:holbegram/models/user.dart';

class UserProvider with ChangeNotifier {
  Users? _user;
  AuthMethods _authMethods = AuthMethods();

  Users? get getUser => _user;

  Future<void> refreshUser() async {
    Users? user = await _authMethods.getUserDetails();
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  void incrementPostCount() {
    if (_user != null) {
      _user!.postCount++;
      notifyListeners();
    }
  }
}
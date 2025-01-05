import 'dart:async';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:flutter/cupertino.dart';

// Fake User class to mimic Firebase User
class User {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;

  User({
    required this.uid,
    required this.email,
    this.displayName = "",
    this.emailVerified = false,
  });

  // Simulate updating display name
  User copyWith({String? displayName, bool? emailVerified}) {
    return User(
      uid: this.uid,
      email: this.email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  Future<void> delete() async {
    // Simulate deleting a user.
    print("User $uid deleted");
  }

  Future<void> sendEmailVerification() async {
    // Simulate sending a verification email.
    print("Verification email sent to $email");
  }
}

class AuthentificationService {
  static const String USER_NOT_FOUND_EXCEPTION_CODE = "user-not-found";
  static const String WRONG_PASSWORD_EXCEPTION_CODE = "wrong-password";
  static const String TOO_MANY_REQUESTS_EXCEPTION_CODE = 'too-many-requests';
  static const String EMAIL_ALREADY_IN_USE_EXCEPTION_CODE =
      "email-already-in-use";
  static const String OPERATION_NOT_ALLOWED_EXCEPTION_CODE =
      "operation-not-allowed";
  static const String WEAK_PASSWORD_EXCEPTION_CODE = "weak-password";
  static const String USER_MISMATCH_EXCEPTION_CODE = "user-mismatch";
  static const String INVALID_CREDENTIALS_EXCEPTION_CODE = "invalid-credential";
  static const String INVALID_EMAIL_EXCEPTION_CODE = "invalid-email";
  static const String USER_DISABLED_EXCEPTION_CODE = "user-disabled";
  static const String INVALID_VERIFICATION_CODE_EXCEPTION_CODE =
      "invalid-verification-code";
  static const String INVALID_VERIFICATION_ID_EXCEPTION_CODE =
      "invalid-verification-id";
  static const String REQUIRES_RECENT_LOGIN_EXCEPTION_CODE =
      "requires-recent-login";

  // Fake user data
  Map<String, Map<String, dynamic>> _users = {};
  User? _currentUser;

  AuthentificationService._privateConstructor();

  static AuthentificationService _instance =
      AuthentificationService._privateConstructor();

  factory AuthentificationService() {
    return _instance;
  }

  // Simulate authStateChanges
  Stream<User?> get authStateChanges {
    return Stream.value(_currentUser);
  }

  // Simulate userChanges
  Stream<User?> get userChanges {
    return Stream.value(_currentUser);
  }

  Future<void> deleteUserAccount() async {
    if (_currentUser != null) {
      _users.remove(_currentUser!.uid);
      await _currentUser!.delete();
      _currentUser = null;
    } else {
      throw Exception("No user signed in");
    }
  }

  Future<bool> reauthCurrentUser(String password) async {
    if (_currentUser == null) {
      throw Exception("No user logged in");
    }
    if (_users[_currentUser!.uid]!['password'] == password) {
      return true;
    } else {
      throw Exception(WRONG_PASSWORD_EXCEPTION_CODE);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    // Find user by email
    String? uid;
    for (var entry in _users.entries) {
      if (entry.value['email'] == email) {
        uid = entry.key;
        break;
      }
    }

    if (uid == null) {
      throw Exception(USER_NOT_FOUND_EXCEPTION_CODE);
    }

    if (_users[uid]!['password'] == password) {
      if (_users[uid]!['emailVerified']) {
        _currentUser = User(
            uid: uid,
            email: email,
            displayName: _users[uid]!['displayName'],
            emailVerified: true);
        return true;
      } else {
        // Simulate sending verification email
        await User(
                uid: uid,
                email: email,
                displayName: _users[uid]!['displayName'],
                emailVerified: false)
            .sendEmailVerification();
        throw Exception("User not verified");
      }
    } else {
      throw Exception(WRONG_PASSWORD_EXCEPTION_CODE);
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    // Check if email is already in use
    for (var entry in _users.entries) {
      if (entry.value['email'] == email) {
        throw Exception(EMAIL_ALREADY_IN_USE_EXCEPTION_CODE);
      }
    }

    // Validate email and password (basic check)
    if (!email.contains('@')) {
      throw Exception(INVALID_EMAIL_EXCEPTION_CODE);
    }
    if (password.length < 6) {
      throw Exception(WEAK_PASSWORD_EXCEPTION_CODE);
    }

    // Create new user
    String uid = DateTime.now().millisecondsSinceEpoch.toString();
    _users[uid] = {
      'email': email,
      'password': password,
      'displayName': '',
      'emailVerified': false
    };
    await User(uid: uid, email: email, displayName: '', emailVerified: false)
        .sendEmailVerification();
    // Simulate creating a new user in the database
    await UserDatabaseHelper().createNewUser(uid);
    return true;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  bool get currentUserVerified {
    return _currentUser?.emailVerified ?? false;
  }

  Future<void> sendVerificationEmailToCurrentUser() async {
    if (_currentUser != null) {
      await _currentUser!.sendEmailVerification();
      _currentUser =
          _currentUser!.copyWith(emailVerified: false); // Reset verification
    }
  }

  User? get currentUser {
    return _currentUser;
  }

  Future<void> updateCurrentUserDisplayName(String updatedDisplayName) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(displayName: updatedDisplayName);
      _users[_currentUser!.uid]!['displayName'] = updatedDisplayName;
    }
  }

  Future<bool> resetPasswordForEmail(String email) async {
    // Check if user with email exists
    String? uid;
    for (var entry in _users.entries) {
      if (entry.value['email'] == email) {
        uid = entry.key;
        break;
      }
    }

    if (uid == null) {
      throw Exception(USER_NOT_FOUND_EXCEPTION_CODE);
    }

    // Simulate sending password reset email (basic implementation)
    print("Password reset email sent to $email");
    return true;
  }

  Future<bool> changePasswordForCurrentUser(
      {String? oldPassword, required String newPassword}) async {
    if (_currentUser == null) {
      throw Exception("No user signed in");
    }
    if (newPassword.length < 6) {
      throw Exception(WEAK_PASSWORD_EXCEPTION_CODE);
    }

    if (oldPassword != null) {
      if (_users[_currentUser!.uid]!['password'] != oldPassword) {
        throw Exception(WRONG_PASSWORD_EXCEPTION_CODE);
      }
    }

    _users[_currentUser!.uid]!['password'] = newPassword;
    return true;
  }

  Future<bool> changeEmailForCurrentUser(
      {String? password, required String newEmail}) async {
    if (_currentUser == null) {
      throw Exception("No user signed in");
    }

    if (password != null) {
      if (_users[_currentUser!.uid]!['password'] != password) {
        throw Exception(WRONG_PASSWORD_EXCEPTION_CODE);
      }
    }

    // Check if new email is already in use
    for (var entry in _users.entries) {
      if (entry.value['email'] == newEmail) {
        throw Exception(EMAIL_ALREADY_IN_USE_EXCEPTION_CODE);
      }
    }

    _users[_currentUser!.uid]!['email'] = newEmail;
    _users[_currentUser!.uid]!['emailVerified'] = false;
    _currentUser = User(
      uid: _currentUser!.uid,
      email: newEmail,
      displayName: _currentUser!.displayName,
      emailVerified: false,
    );

    // Simulate sending verification email for new email
    await _currentUser!.sendEmailVerification();
    return true;
  }

  Future<bool> verifyCurrentUserPassword(String password) async {
    if (_currentUser == null) {
      throw Exception("No user signed in");
    }
    return _users[_currentUser!.uid]!['password'] == password;
  }
}

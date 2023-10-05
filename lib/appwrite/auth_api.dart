import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';
import 'package:encrypt/encrypt.dart' as crypto;

import 'constants.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends ChangeNotifier {
  Client client = Client();
  late final Account account;

  late User _currentUser;

  AuthStatus _status = AuthStatus.uninitialized;

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser.name;
  String? get email => _currentUser.email;
  String? get userid => _currentUser.$id;

  // Constructor
  AuthAPI() {
    init();
    loadUser();
  }

  // Initialize the Appwrite client
  void init() {
    client
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned();
    account = Account(client);
  }

  void loadUser() async {
    try {
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<User> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return user;
    } finally {
      notifyListeners();
    }
  }

  Future<Session> createEmailSession({
    required String email,
    required String password,
  }) async {
    try {
      final session =
          await account.createEmailSession(email: email, password: password);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  Future<User> updateEmail({
    required String email,
    required String password,
  }) async {
    return account.updateEmail(email: email, password: password);
  }

  Future<User> updateName({required String name}) async {
    return account.updateName(name: name);
  }

  Future<User> updatePassword({required String password}) async {
    return account.updatePassword(password: password);
  }

  Future<dynamic> signInWithProvider({required String provider}) async {
    try {
      final session = await account.createOAuth2Session(provider: provider);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  void signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<Preferences> getUserPreferences() async {
    return await account.getPrefs();
  }

  Future<User> updatePreferences({required String bio}) async {
    return account.updatePrefs(prefs: {'bio': bio});
  }

  Future<String> initSalt() async {
    var p = (await account.getPrefs()).data;
    try {
      if (base64Decode(p["salt"]).length != 32) {
        // must be 32 bytes
        throw Exception("Not 32 bytes");
      }
    } catch (e) {
      // override corrupted salt (will probably corrupt remote data)
      p["salt"] = crypto.Key.fromSecureRandom(32).base64;
      account.updatePrefs(prefs: p);
    }
    return p["salt"];
  }
}

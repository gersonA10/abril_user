// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_user/functions/models/code_whats_app.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

class SignInProvider with ChangeNotifier {
  final _googleSignIn = GoogleSignIn();
  bool _isAuth = false;
  bool _loadingAuth = false;
  bool _loadingValidate = true;
  bool _loadingDeleteAccount = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _userInfo;

  bool get isAuth => _isAuth;
  bool get loadingAuth => _loadingAuth;
  bool get loadingValidate => _loadingValidate;
  bool get loadingDeleteAccount => _loadingDeleteAccount;

  set loadingValidate(bool state) {
    _loadingValidate = state;
    notifyListeners();
  }

  set loadingAuth(bool state) {
    _loadingAuth = state;
    notifyListeners();
  }

  set loadingDeleteAccount(bool state) {
    _loadingDeleteAccount = state;
    notifyListeners();
  }

  set isAuth(bool state) {
    _isAuth = state;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  User? get userInfo => _userInfo;
  set userInfo(User? user) {
    _userInfo = user;
  }

  /// validar estado de token de usuario En firebase
  void validateToken() async {
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _userInfo = user;
          if (!isAuth) {
            isAuth = true;
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<User?> googleAuth() async {
    try {
      loadingAuth = true;
      var googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        var googleAuth = await googleUser.authentication;

        var credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        var resInfo = await _auth.signInWithCredential(credential);
        _userInfo = resInfo.user!;
        var storage = await SharedPreferences.getInstance();
        storage.setString('uid_user', resInfo.user!.uid);

        isAuth = true;
      }
      loadingAuth = false;
      return _userInfo;
    } on PlatformException catch (e) {
      loadingAuth = false;
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  // Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> appleAuth() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      var resInfo = await _auth.signInWithCredential(oauthCredential);
      _userInfo = resInfo.user!;
      var storage = await SharedPreferences.getInstance();
      storage.setString('uid_user', resInfo.user!.uid);
      // await _identifyUser(resInfo.user!.email!, "APPLE");
      isAuth = true;
      loadingAuth = false;
    } on FirebaseAuthException catch (e) {
      loadingAuth = false;
      if (kDebugMode) {
        print(e);
      }
    } catch (e) {
      loadingAuth = false;
    }
  }

  // Future<void> _identifyUser(String email, String accessType) async {
  //   await postAuthClientToken();
  //   var existUser = await getExistsUser(_userInfo.email!);
  //   if (existUser.id != null) {
  //     await postAuthUserToken(existUser.email);
  //   } else {
  //     var userData = await postCreateUser(
  //         email: _userInfo.email!,
  //         fullName: _userInfo.displayName ?? '',
  //         photoUrl: _userInfo.photoURL ?? ' ',
  //         accessType: accessType);
  //     await postAuthUserToken(userData.email);
  //   }
  // }

  Future<void> logOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<CodeWhatsApp?> sendCodeWhatsApp(
      {required String number, required String code}) async {
    try {
      String url =
          "https://15deabril.macrobyte.site/api/whatsapp/code?telefono=$number&code=$code";

      var res = await http.get(Uri.parse(url));
      print(res.body);
      if (res.statusCode == 200) {
        return codeWhatsAppFromJson(res.body);
      }
      if (res.statusCode == 409) {
        return codeWhatsAppFromJson(res.body);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}

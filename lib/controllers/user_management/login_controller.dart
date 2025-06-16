import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  bool rememberMe = false;
  bool isLoading = false;
  bool attemptedLogin = false;


  bool emailErrorVisible = false;
  bool passwordErrorVisible = false;

  bool isLoginEnabled = false;

  bool isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  bool isValidPassword(String password) => password.length >= 6;

void updateButtonState(String email, String password) {
  if (attemptedLogin) {
    emailErrorVisible = !isValidEmail(email);
    passwordErrorVisible = !isValidPassword(password);
  }

  isLoginEnabled = isValidEmail(email) && isValidPassword(password);
  notifyListeners();
}


  Future<Map<String, dynamic>> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final remember = savedEmail != null && savedPassword != null;
    if (remember) {
      return {
        'email': savedEmail,
        'password': savedPassword,
        'rememberMe': true,
      };
    }
    return {'email': '', 'password': '', 'rememberMe': false};
  }

  Future<String?> login({
  required String email,
  required String password,
}) async {
  attemptedLogin = true;
  emailErrorVisible = !isValidEmail(email);
  passwordErrorVisible = !isValidPassword(password);

  if (emailErrorVisible || passwordErrorVisible) {
    notifyListeners();
    return 'Please fix the errors in the form.';
  }

  isLoading = true;
  notifyListeners();

  try {
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final result = await handleUserNavigation(
        userCredential.user, rememberMe, email, password);

    isLoading = false;
    notifyListeners();

    return result;
  } on FirebaseAuthException catch (e) {
    isLoading = false;
    notifyListeners();

    switch (e.code) {
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return 'Login failed. ${e.message ?? 'Unknown error.'}';
    }
  } catch (e) {
    isLoading = false;
    notifyListeners();
    return 'Something went wrong. Please try again.';
  }
}

  Future<String?> handleUserNavigation(User? user, bool rememberMe, String email, String password) async {
    if (user == null) return 'Login failed. Please try again.';

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userDoc.exists) return 'User data not found.';

    final userData = userDoc.data();
    final status = userData?['status'] ?? 'pending';
    final role = userData?['role'] ?? 'User';

    if (role == 'Service Provider' && status == 'pending') {
      await FirebaseAuth.instance.signOut();
      return 'Your account is awaiting admin approval.';
    }

    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
    await prefs.setString('uid', user.uid);
    await prefs.setString('role', role);

    return null;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (_) {
      return null;
    }
  }
}

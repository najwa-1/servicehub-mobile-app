import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/user_management/login_controller.dart';
import '../../forms/login_form.dart';
import '../services/services_display_page.dart';
import '../services/services_page.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _onLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'User';

    if (role == 'Service Provider') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ServicesPage()),
                    );
                  } else {
                    final snapshot = await FirebaseFirestore.instance.collection('services').get();
                    final List<Map<String, dynamic>> servicesList = snapshot.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ServicesDisplayPage(services: servicesList)),
                    );
                  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LoginForm(
          controller: _controller,
          showError: _showError,
          onLoginSuccess: _onLoginSuccess,
        ),
      ),
    );
  }
}

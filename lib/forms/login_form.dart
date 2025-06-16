import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../controllers/user_management/login_controller.dart';
import '../widgets/text_fields/login_text_field.dart';
import '../theme/app_colors.dart';
import '../routes/appRoutes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class LoginForm extends StatefulWidget {
  final LoginController controller;
  final void Function(String message) showError;
  final Future<void> Function() onLoginSuccess;

  const LoginForm({
    Key? key,
    required this.controller,
    required this.showError,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    widget.controller.addListener(_onControllerUpdate);

    _loadSavedCredentials();

    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  void _updateButtonState() {
    widget.controller.updateButtonState(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  Future<void> _loadSavedCredentials() async {
    final saved = await widget.controller.loadSavedCredentials();
    _emailController.text = saved['email'] ?? '';
    _passwordController.text = saved['password'] ?? '';
    widget.controller.rememberMe = saved['rememberMe'] ?? false;
    widget.controller.updateButtonState(_emailController.text, _passwordController.text);
  }

  Future<void> _onLoginPressed() async {
    final error = await widget.controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (error != null) {
      widget.showError(error);
    } else {
      await widget.onLoginSuccess();
    }
  }

  Future<void> _onGoogleSignInPressed() async {
    final user = await widget.controller.signInWithGoogle();
    if (user == null) {
      widget.showError('Google sign-in failed.');
    } else {
      final error = await widget.controller.handleUserNavigation(
        user,
        widget.controller.rememberMe,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (error != null) {
        widget.showError(error);
      } else {
        await widget.onLoginSuccess();
      }
    }
  }

  Widget buildHeader() {
  return Column(
    children:  [
      SizedBox(height: 100.h),
      Center(child: Image(image: AssetImage('assets/images/logo.png'), height: 120)),
      SizedBox(height: 20),
  
    ],
  );
}


Widget buildForm() {
  final c = widget.controller;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LoginTextField(
        controller: _emailController,
        labelText: "Email",
        hintText: "Enter your email",
        obscureText: false,
        showError: c.emailErrorVisible,
        errorText: "Please enter a valid email address",
        onChanged: (_) => _updateButtonState(),
      ),
      const SizedBox(height: 20),
      LoginTextField(
        controller: _passwordController,
        labelText: "Password",
        hintText: "Enter your password",
        obscureText: _obscurePassword,
        showError: c.passwordErrorVisible,
        errorText: "Password must be at least 6 characters",
        toggleObscure: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
        onChanged: (_) => _updateButtonState(),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Checkbox(
            value: c.rememberMe,
            onChanged: (value) {
              c.rememberMe = value ?? false;
              c.notifyListeners();
            },
            visualDensity: VisualDensity.compact,
          ),
           Text('Remember me', style: TextStyle(fontSize: 14.sp)),
        ],
      ),
       SizedBox(height: 10.h),
      c.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6,
                padding:  EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                backgroundColor: c.isLoginEnabled ? AppColors.primary : AppColors.disabled,
              ),
              onPressed: c.isLoginEnabled ? _onLoginPressed : null,
              child:  Text(
                'Login',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
    ],
  );
}

Widget buildFooter() {
  return Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.forgotPassword);
          },
          child:  Text('Forgot Password?', style: TextStyle(fontSize: 14.sp)),
        ),
      ),
       SizedBox(height: 10.h),
      Row(
        children:  [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.h),
            child: Text("OR"),
          ),
          Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        icon: const Icon(Icons.g_mobiledata),
        label: const Text("Sign in with Gmail"),
        onPressed: _onGoogleSignInPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 224, 94, 85),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      const SizedBox(height: 30),
      RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: "Create one",
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacementNamed(context, '/role-selection');
                },
            ),
          ],
        ),
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return SingleChildScrollView(
      padding:  EdgeInsets.symmetric(horizontal: 24.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           SizedBox(height: 90.h),
          Center(child: Image.asset('assets/images/logo.png', height: 120.h)),
           SizedBox(height: 40.h),
          LoginTextField(
            controller: _emailController,
            labelText: "Email",
            hintText: "Enter your email",
            obscureText: false,
            showError: c.emailErrorVisible,
            errorText: "Please enter a valid email address",
            onChanged: (_) => _updateButtonState(),
          ),
           SizedBox(height: 20.h),
          LoginTextField(
            controller: _passwordController,
            labelText: "Password",
            hintText: "Enter your password",
            obscureText: _obscurePassword,
            showError: c.passwordErrorVisible,
            errorText: "Password must be at least 6 characters",
            toggleObscure: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            onChanged: (_) => _updateButtonState(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: c.rememberMe,
                    onChanged: (value) {
                      c.rememberMe = value ?? false;
                      c.notifyListeners();
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                   Text('Remember me', style: TextStyle(fontSize: 13.sp)),
                ],
              ),
              TextButton(
                onPressed: () {
              Navigator.pushNamed(context, AppRoutes.forgotPassword);

                },
                child:  Text('Forgot Password?', style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
           SizedBox(height: 20.h),
          c.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    padding:  EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor:
                        c.isLoginEnabled ? AppColors.primary : AppColors.disabled,
                  ),
                  onPressed: c.isLoginEnabled ? _onLoginPressed : null,
                  child:  Text(
                    'Login',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
           SizedBox(height: 20.h),
          Row(
            children:  [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.h),
                child: Text("OR"),
              ),
              Expanded(child: Divider()),
            ],
          ),
           SizedBox(height: 20.h),
          ElevatedButton.icon(
            icon: const Icon(Icons.g_mobiledata),
            label: const Text("Sign in with Gmail"),
            onPressed: _onGoogleSignInPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 224, 94, 85),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
           SizedBox(height: 20.h),
          Center(
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: "Create one",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacementNamed(context, '/role-selection');
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../controllers/user_management/create_account_controller.dart';
import '../models/profile/user_model.dart';
import '../theme/app_colors.dart';
import '../views/user_management/login.dart';
import '../widgets/text_fields/custom_text_field.dart';


class CreateAccountForm extends StatefulWidget {
  final String role;
  const CreateAccountForm({required this.role, super.key});

  @override
  State<CreateAccountForm> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  bool _isFormValid = false;

  final controller = CreateAccountController();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _location = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

 @override
void initState() {
  super.initState();

  _firstName.addListener(_validateForm);
  _lastName.addListener(_validateForm);
  _email.addListener(_validateForm);
  _phone.addListener(_validateForm);
  _password.addListener(_validateForm);
  _confirmPassword.addListener(_validateForm);
  _location.addListener(_validateForm);

  _fetchLocationAutomatically();
}

void _fetchLocationAutomatically() async {
  final error = await controller.fetchLocation(_location);
  if (error != null) {
    _showMessage(error, Colors.red);
  }
}


  void _validateForm() {
    final isValid = 
      _firstName.text.isNotEmpty &&
      _lastName.text.isNotEmpty &&
      _email.text.isNotEmpty &&
      _phone.text.isNotEmpty &&
      _password.text.isNotEmpty &&
      _confirmPassword.text.isNotEmpty &&
      _location.text.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _location.dispose();
    super.dispose();
  }

  void _submit() async {
    final error = controller.validateInput(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
      confirmPassword: _confirmPassword.text,
      location: _location.text,
    );

    if (error != null) {
      _showMessage(error, Colors.red);
      return;
    }

    setState(() => _loading = true);

    final userModel = UserModel(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
      location: _location.text,
      role: widget.role,
    );

    final result =
        await controller.createUser(userModel: userModel, password: _password.text);

    setState(() => _loading = false);

    if (result != null) {
      _showMessage(result, Colors.red);
    } else {
      _showMessage(
          widget.role == 'Service Provider'
              ? 'Account created. Waiting for admin approval.'
              : 'Account created successfully.',
          Colors.green);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(label: 'First Name', controller: _firstName, hint: 'Enter your first name'),
        CustomTextField(label: 'Last Name', controller: _lastName, hint: 'Enter your last name'),
        CustomTextField(
            label: 'Email',
            controller: _email,
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress),
        CustomTextField(
            label: 'Phone Number',
            controller: _phone,
            hint: 'Enter your phone',
            keyboardType: TextInputType.phone),
        CustomTextField(
          label: 'Password',
          controller: _password,
          hint: 'Enter your password',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        CustomTextField(
          label: 'Confirm Password',
          controller: _confirmPassword,
          hint: 'Re-enter password',
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
        TextFormField(
          controller: _location,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Location',
            hintText: 'Tap the icon to fetch location',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _location.clear(),
                ),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () => controller.fetchLocation(_location),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _isFormValid && !_loading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: _isFormValid
                      ? Theme.of(context).primaryColor
                      : AppColors.disabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Create Account',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
        const SizedBox(height: 16),
   Padding(
  padding: const EdgeInsets.only(top: 16),
  child: RichText(
    text: TextSpan(
      text: 'Already have an account? ',
      style: TextStyle(color: Colors.black87, fontSize: 16),
      children: [
        TextSpan(
          text: 'Login',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
        ),
      ],
    ),
  ),
),

      ],
    );
  }
}

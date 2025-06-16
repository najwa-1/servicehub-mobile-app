class ResetPasswordModel {
  String newPassword = '';
  String confirmPassword = '';

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}

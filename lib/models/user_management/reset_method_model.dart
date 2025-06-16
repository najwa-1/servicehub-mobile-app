enum ResetMethod { email, sms }

class ResetData {
  String contact = '';
  ResetMethod method = ResetMethod.email;

  bool get isValid {
    if (method == ResetMethod.email) {
      return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(contact);
    } else {
      return RegExp(r'^\+?[0-9]{10,13}$').hasMatch(contact);
    }
  }

  String get label => method == ResetMethod.email ? 'Email' : 'Phone Number';
  String get hint =>
      method == ResetMethod.email ? 'Enter your email' : 'Enter your phone number';
}

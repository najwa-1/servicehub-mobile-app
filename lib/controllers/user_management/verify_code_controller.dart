import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_management/verify_code_model.dart';


class VerifyCodeController {
  final VerifyCodeModel model;

  VerifyCodeController(this.model);

  void updateDigit(int index, String value) {
    if (index >= 0 && index < model.digits.length) {
      model.digits[index] = value;
    }
  }

  bool get isCodeComplete => model.isComplete;

  Future<void> verifyCode({
    required String verificationId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: model.code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }
}

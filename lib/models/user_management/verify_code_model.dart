class VerifyCodeModel {
  final List<String> digits;

  VerifyCodeModel({List<String>? digits})
      : digits = digits ?? List.filled(6, '');

  String get code => digits.join();

  bool get isComplete => digits.every((d) => d.isNotEmpty);
}

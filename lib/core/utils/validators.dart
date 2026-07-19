/// Form field validators with Arabic error messages.
abstract final class Validators {
  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'حقل $label مطلوب';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, 'البريد الإلكتروني');
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, 'كلمة المرور');
    if (requiredError != null) return requiredError;

    if (value!.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  static String? pinCode(String? value) {
    final requiredError = requiredField(value, 'رمز التحقق');
    if (requiredError != null) return requiredError;

    if (!RegExp(r'^\d{5}$').hasMatch(value!)) {
      return 'رمز التحقق يجب أن يكون 5 أرقام';
    }
    return null;
  }
}

import 'package:zaizen/l10n/app_strings.dart';

/// Oddiy, lekin mustahkam parol/email/ism tekshiruvi.
class PasswordRules {
  PasswordRules._();

  static const minLength = 8;
  static const maxLength = 72;

  static const _weak = {
    'password',
    'password1',
    'password123',
    'qwerty',
    'qwerty123',
    '12345678',
    '123456789',
    '1234567890',
    '11111111',
    '00000000',
    'abcdefgh',
    'letmein',
    'welcome',
    'admin123',
    'zaizen',
    'zaizen123',
    'parol123',
    'qwertyui',
    'iloveyou',
    'abc12345',
  };

  static final _emailRe = RegExp(r'[^\s@]+@[^\s@]+\.[^\s@]{2,}');
  static final _letterRe = RegExp(r'[A-Za-zА-яЁёЎўҚқҒғҲҳ]');
  static final _digitRe = RegExp(r'\d');

  static String? emailError(String email) {
    final s = LanguageScope.strings;
    final v = email.trim();
    if (v.isEmpty) return s.authEnterEmail;
    if (!_emailRe.hasMatch(v)) return s.authBadEmail;
    return null;
  }

  static String? nameError(String name) {
    final s = LanguageScope.strings;
    final v = name.trim();
    if (v.isEmpty) return s.authEnterName;
    if (v.length < 2) return s.authNameShort;
    return null;
  }

  static String? passwordError(String password, {String? email}) {
    final s = LanguageScope.strings;
    final p = password;
    if (p.isEmpty) return s.authEnterPassword;
    if (p.contains(' ')) return s.authPasswordSpace;
    if (p.length < minLength) return s.authPasswordShort;
    if (p.length > maxLength) return s.authPasswordShort;
    if (!_letterRe.hasMatch(p)) return s.authPasswordLetter;
    if (!_digitRe.hasMatch(p)) return s.authPasswordDigit;
    if (_weak.contains(p.toLowerCase())) return s.authPasswordCommon;
    if (email != null && email.trim().isNotEmpty) {
      final local = email.trim().split('@').first.toLowerCase();
      if (local.length >= 3 && p.toLowerCase().contains(local)) {
        return s.authPasswordLikeEmail;
      }
    }
    return null;
  }

  static String? confirmError(String password, String confirm) {
    final s = LanguageScope.strings;
    if (confirm.isEmpty) return s.authConfirmPassword;
    if (password != confirm) return s.authPasswordMismatch;
    return null;
  }

  static int strength(String password) {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= minLength) score++;
    if (password.length >= 12) score++;
    if (_letterRe.hasMatch(password) && _digitRe.hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    if (_weak.contains(password.toLowerCase())) score = score.clamp(0, 1);
    return score.clamp(0, 4);
  }

  static String strengthLabel(int score) {
    final code = LanguageScope.code;
    switch (score) {
      case 0:
      case 1:
        return {'uz': 'Zaif', 'ru': 'Слабый', 'ja': '弱い'}[code] ?? 'Weak';
      case 2:
        return {'uz': "O'rtacha", 'ru': 'Средний', 'ja': '普通'}[code] ?? 'Fair';
      case 3:
        return {'uz': 'Yaxshi', 'ru': 'Хороший', 'ja': '良い'}[code] ?? 'Good';
      default:
        return {'uz': 'Mustahkam', 'ru': 'Надёжный', 'ja': '強い'}[code] ?? 'Strong';
    }
  }
}

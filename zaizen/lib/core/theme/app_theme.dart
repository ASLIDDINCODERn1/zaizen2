import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'app_is_dark';
  bool _isDark = true;
  bool _ready = false;

  bool get isDark => _isDark;
  bool get ready => _ready;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? true;
    _ready = true;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

class ZColors {
  final bool isDark;
  const ZColors(this.isDark);

  static ZColors of(BuildContext context) {
    return ZColors(context.watch<ThemeProvider>().isDark);
  }

  Color get bgTop => isDark ? const Color(0xFF0D1526) : const Color(0xFFF3F6FB);
  Color get bgBottom => isDark ? const Color(0xFF05070C) : const Color(0xFFE7EDF6);
  Color get surface => isDark ? const Color(0xFF11151F) : const Color(0xFFFFFFFF);
  Color get border => isDark ? const Color(0xFF232838) : const Color(0xFFD7E0EC);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get textSecondary => isDark ? const Color(0xFF9AA3B2) : const Color(0xFF475569);
  Color get textMuted => isDark ? const Color(0xFF6B7280) : const Color(0xFF64748B);
  Color get primary => const Color(0xFF3B82F6);
  Color get danger => const Color(0xFFEF4444);
}

class PageGutters {
  static EdgeInsets of(BuildContext context, {double bottom = 110}) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final x = size.width < 360 ? 14.0 : size.width > 430 ? 28.0 : 20.0;
    final top = pad.top + (size.height < 700 ? 6.0 : 12.0);
    return EdgeInsets.fromLTRB(x, top, x, bottom);
  }

  static double navSide(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return 12;
    if (w > 430) return 28;
    return 18;
  }
}

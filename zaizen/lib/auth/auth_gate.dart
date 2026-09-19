import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/pages/homepage.dart';
import 'package:zaizen/pages/login.dart';
import 'package:zaizen/pages/profile_menus/app_lock.dart';
import 'package:zaizen/pages/update_password.dart';
import 'package:zaizen/ui/language_picker_bar.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  Session? _session;
  AuthChangeEvent? _event;
  StreamSubscription<AuthState>? _sub;
  bool _checkingPin = true;
  bool _hasPin = false;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = AuthService.instance.session;
    _sub = AuthService.instance.authChanges.listen((data) {
      if (!mounted) return;
      setState(() {
        _event = data.event;
        _session = data.session ?? AuthService.instance.session;
      });
      _refreshPin();
    });
    _refreshPin();
  }

  Future<void> _refreshPin() async {
    try {
      final pin = await SecurityHelper.getSavedPin();
      if (!mounted) return;
      final has = pin != null && pin.isNotEmpty;
      setState(() {
        _hasPin = has;
        _checkingPin = false;
        if (!has) _unlocked = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingPin = false;
        _hasPin = false;
        _unlocked = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (_hasPin && _unlocked && mounted) {
        setState(() => _unlocked = false);
      }
    }
    if (state != AppLifecycleState.resumed) return;
    final current = AuthService.instance.session;
    if (!mounted) return;
    if (current?.accessToken != _session?.accessToken) {
      setState(() => _session = current);
    }
    _refreshPin();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session ?? AuthService.instance.session;
    if (_event == AuthChangeEvent.passwordRecovery) {
      return const UpdatePasswordScreen();
    }
    if (session == null) {
      return const _LoginWithLanguage();
    }
    if (_checkingPin) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A3D91),
        body: Center(child: CupertinoActivityIndicator(color: Colors.white)),
      );
    }
    if (_hasPin && !_unlocked) {
      return AppLockScreen(
        onAuthenticated: () {
          if (mounted) setState(() => _unlocked = true);
        },
      );
    }
    return const HomeScreen();
  }
}

class _LoginWithLanguage extends StatelessWidget {
  const _LoginWithLanguage();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        LoginScreen(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: LanguagePickerBar(),
            ),
          ),
        ),
      ],
    );
  }
}

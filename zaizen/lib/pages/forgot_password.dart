import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/auth/password_rules.dart';
import 'package:zaizen/l10n/l10n_scope.dart';
import 'package:zaizen/pages/login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _ok = false;
  late final AnimationController _in;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final err = PasswordRules.emailError(_email.text);
    if (err != null) {
      setState(() {
        _ok = false;
        _message = err;
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await AuthService.instance.resetPassword(_email.text);
      setState(() {
        _ok = true;
        _message = L.read(context).authResetSent;
      });
    } catch (e) {
      setState(() {
        _ok = false;
        _message = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = L.of(context);
    final fade = CurvedAnimation(parent: _in, curve: Curves.easeOutCubic);
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(s.resetPasswordTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(fade),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.resetPasswordDesc,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _ok ? const Color(0xFF22C55E) : AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                CupertinoButton(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _loading ? null : _send,
                  child: _loading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text(s.sendResetLink, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

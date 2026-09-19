import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/auth/password_rules.dart';
import 'package:zaizen/l10n/l10n_scope.dart';
import 'package:zaizen/pages/login.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _pass.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final passErr = PasswordRules.passwordError(
      _pass.text,
      email: AuthService.instance.email,
    );
    if (passErr != null) {
      setState(() {
        _ok = false;
        _message = passErr;
      });
      return;
    }
    final confirmErr = PasswordRules.confirmError(_pass.text, _confirm.text);
    if (confirmErr != null) {
      setState(() {
        _ok = false;
        _message = confirmErr;
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await AuthService.instance.updatePassword(_pass.text);
      if (!mounted) return;
      setState(() {
        _ok = true;
        _message = L.read(context).passwordUpdated;
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
    final score = PasswordRules.strength(_pass.text);
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(s.newPasswordTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            s.newPasswordRules,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _field(s.newPasswordTitle, _pass),
          const SizedBox(height: 10),
          Text(
            _pass.text.isEmpty
                ? s.passwordHintShort
                : PasswordRules.strengthLabel(score),
            style: TextStyle(
              color: score >= 3
                  ? const Color(0xFF22C55E)
                  : score == 2
                      ? const Color(0xFFEAB308)
                      : AppColors.error,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _field(s.confirmPassword, _confirm),
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
            onPressed: _loading ? null : _save,
            child: _loading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(s.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
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
      ],
    );
  }
}

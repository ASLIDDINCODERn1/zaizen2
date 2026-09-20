import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/auth/password_rules.dart';
import 'package:zaizen/l10n/l10n_scope.dart';
import 'package:zaizen/pages/forgot_password.dart';

class AppColors {
  static const bgTop = Color(0xFF0A0E17);
  static const bgBottom = Color(0xFF0A0E17);
  static const surface = Color(0xFF11151F);
  static const surfaceFocused = Color(0xFF161C2C);
  static const border = Color(0xFF232838);
  static const borderFocused = Color(0xFF3B82F6);
  static const primary = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF2563EB);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9AA3B2);
  static const textMuted = Color(0xFF6B7280);
  static const error = Color(0xFFEF4444);
}

class LoginScreen extends StatefulWidget {
  final bool startOnSignUp;
  const LoginScreen({super.key, this.startOnSignUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late bool _isSignUp;
  bool _obscure = true;
  bool _obscure2 = true;
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.startOnSignUp;
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _passCtrl.addListener(_onPassChanged);
  }

  void _onPassChanged() {
    if (_isSignUp && mounted) setState(() {});
  }

  @override
  void dispose() {
    _enter.dispose();
    _passCtrl.removeListener(_onPassChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFFEF4444) : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.mediumImpact();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final emailErr = PasswordRules.emailError(email);
    if (emailErr != null) {
      _toast(emailErr, error: true);
      return;
    }
    if (_isSignUp) {
      final nameErr = PasswordRules.nameError(_nameCtrl.text);
      if (nameErr != null) {
        _toast(nameErr, error: true);
        return;
      }
      final passErr = PasswordRules.passwordError(pass, email: email);
      if (passErr != null) {
        _toast(passErr, error: true);
        return;
      }
      final confirmErr = PasswordRules.confirmError(pass, _confirmCtrl.text);
      if (confirmErr != null) {
        _toast(confirmErr, error: true);
        return;
      }
    } else if (pass.isEmpty) {
      _toast(L.read(context).authEnterPassword, error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isSignUp) {
        final res = await AuthService.instance.signUpWithEmail(
          email: email,
          password: pass,
          fullName: _nameCtrl.text.trim(),
        );
        if (!mounted) return;
        if (res.session == null) {
          _toast(L.read(context).authAccountCreated);
          setState(() => _isSignUp = false);
        }
      } else {
        await AuthService.instance.signInWithEmail(email, pass);
      }
    } catch (e) {
      _toast(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final s = L.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.bgTop, AppColors.bgBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _enter,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(22, 8, 22, 24 + bottom),
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x14FFFFFF)),
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'ZAIZEN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isSignUp ? s.createAccount : s.signInHint,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                          decoration: BoxDecoration(
                            color: const Color(0xF20E1420),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _ModeSwitch(
                                isSignUp: _isSignUp,
                                onChanged: (v) {
                                  if (v == _isSignUp) return;
                                  setState(() => _isSignUp = v);
                                },
                              ),
                              const SizedBox(height: 18),
                              if (_isSignUp) ...[
                                _Field(
                                  label: s.nameLabel,
                                  hint: 'Asliddin',
                                  controller: _nameCtrl,
                                  icon: CupertinoIcons.person,
                                ),
                                const SizedBox(height: 12),
                              ],
                              _Field(
                                label: s.email,
                                hint: 'you@email.com',
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                icon: CupertinoIcons.mail,
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                label: s.password,
                                hint: '••••••••',
                                controller: _passCtrl,
                                obscure: _obscure,
                                icon: CupertinoIcons.lock,
                                suffix: _Eye(
                                  obscure: _obscure,
                                  onTap: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              if (_isSignUp) ...[
                                const SizedBox(height: 10),
                                _PasswordStrengthBar(password: _passCtrl.text),
                                const SizedBox(height: 12),
                                _Field(
                                  label: s.confirmPassword,
                                  hint: '••••••••',
                                  controller: _confirmCtrl,
                                  obscure: _obscure2,
                                  icon: CupertinoIcons.lock_shield,
                                  suffix: _Eye(
                                    obscure: _obscure2,
                                    onTap: () =>
                                        setState(() => _obscure2 = !_obscure2),
                                  ),
                                ),
                              ],
                              if (!_isSignUp)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.only(top: 8),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      s.forgotPassword,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    minimumSize: Size(0, 0),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              _PrimaryButton(
                                label: _isSignUp ? s.signUp : s.signIn,
                                loading: _loading,
                                onTap: _loading ? () {} : _handleSubmit,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSignUp ? s.dataSafe : s.continueNeedLogin,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final bool isSignUp;
  final ValueChanged<bool> onChanged;
  const _ModeSwitch({required this.isSignUp, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = L.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _chip(s.signIn, !isSignUp, () => onChanged(false)),
          _chip(s.signUp, isSignUp, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: active ? AppColors.primary : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.borderFocused,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  @override
  Widget build(BuildContext context) {
    final score = PasswordRules.strength(password);
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFF97316),
      const Color(0xFFEAB308),
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
    ];
    final color = colors[score.clamp(0, 4)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final on = score > i;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                decoration: BoxDecoration(
                  color: on ? color : const Color(0xFF232838),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          password.isEmpty
              ? L.of(context).passwordHintShort
              : PasswordRules.strengthLabel(score),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Eye extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;
  const _Eye({required this.obscure, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
        color: AppColors.textMuted,
        size: 18,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

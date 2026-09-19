import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/profile_menus/app_lock.dart';
import 'package:zaizen/ui/app_theme.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _hasPin = false;
  bool _isFingerprintSupported = false;
  bool _isFingerprintEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    try {
      final pin = await SecurityHelper.getSavedPin();
      final fpSupported = await SecurityHelper.isFingerprintAvailable();
      final fpEnabled = await SecurityHelper.isFingerprintEnabled();
      if (!mounted) return;
      setState(() {
        _hasPin = pin != null && pin.isNotEmpty;
        _isFingerprintSupported = fpSupported;
        _isFingerprintEnabled = fpEnabled;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openPinSetup() async {
    final saved = await Navigator.push<bool>(
      context,
      CupertinoPageRoute(
        builder: (_) => const AppLockScreen(isInitialSetup: true),
      ),
    );
    if (saved == true || mounted) {
      await _loadSecurityStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final c = ZColors.of(context);
    return Scaffold(
      backgroundColor: c.bgBottom,
      appBar: AppBar(
        backgroundColor: c.bgTop,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.chevron_back, color: c.textPrimary),
          minimumSize: Size(0, 0),
        ),
        title: Text(
          s.security,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.bgTop, c.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator(color: c.primary))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Text(
                    s.deviceProtection,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Card(
                    child: Column(
                      children: [
                        _Row(
                          icon: CupertinoIcons.lock_shield_fill,
                          label: _hasPin ? s.changePin : s.setPin,
                          onTap: _openPinSetup,
                        ),
                        if (_hasPin) ...[
                          Divider(height: 1, color: c.border, indent: 64),
                          _Row(
                            icon: CupertinoIcons.trash,
                            label: s.deletePin,
                            danger: true,
                            onTap: _confirmRemovePin,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    s.biometricProtection,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              CupertinoIcons.person_crop_circle_badge_checkmark,
                              color: c.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.fingerprintToggle,
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _hasPin
                                      ? s.fingerprintToggleDesc
                                      : s.fingerprintNeedPin,
                                  style: TextStyle(
                                    color: c.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: _hasPin && _isFingerprintEnabled,
                            activeTrackColor: c.primary,
                            onChanged: !_hasPin
                                ? null
                                : (val) async {
                                    if (val) {
                                      final ok =
                                          await SecurityHelper.authenticateWithBiometrics();
                                      if (ok) {
                                        await SecurityHelper.setFingerprintEnabled(
                                          true,
                                        );
                                        if (mounted)
                                          setState(
                                            () => _isFingerprintEnabled = true,
                                          );
                                      }
                                    } else {
                                      await SecurityHelper.setFingerprintEnabled(
                                        false,
                                      );
                                      if (mounted)
                                        setState(
                                          () => _isFingerprintEnabled = false,
                                        );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.info_circle_fill,
                          color: c.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.securityHint,
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmRemovePin() {
    final s = context.read<LocaleProvider>().strings;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(s.deletePin),
        content: Text(s.confirmDeletePin),
        actions: [
          CupertinoDialogAction(
            child: Text(s.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(s.delete),
            onPressed: () async {
              await SecurityHelper.removePin();
              if (ctx.mounted) Navigator.pop(ctx);
              await _loadSecurityStatus();
            },
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final color = danger ? c.danger : c.primary;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: danger ? color : c.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
            if (!danger)
              Icon(CupertinoIcons.chevron_right, color: c.textMuted, size: 16),
          ],
        ),
      ),
      minimumSize: Size(0, 0),
    );
  }
}

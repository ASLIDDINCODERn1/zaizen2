import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/profile_menus/language_screen.dart';
import 'package:zaizen/pages/profile_menus/profile_sub.dart'
    hide LanguageScreen;
import 'package:zaizen/pages/profile_menus/security_tab.dart';
import 'package:zaizen/ui/app_theme.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final theme = context.watch<ThemeProvider>();
    final c = ZColors.of(context);
    return ListView(
      padding: PageGutters.of(context),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          s.settingsTitle,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _IconBox(
                  icon: theme.isDark
                      ? CupertinoIcons.moon_fill
                      : CupertinoIcons.sun_max_fill,
                  color: c.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appearance,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        theme.isDark ? s.darkMode : s.lightMode,
                        style: TextStyle(color: c.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: theme.isDark,
                  activeTrackColor: c.primary,
                  onChanged: theme.setDark,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          child: Column(
            children: [
              _RowItem(
                icon: CupertinoIcons.bell_fill,
                label: s.notifications,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              const _Line(),
              _RowItem(
                icon: CupertinoIcons.lock_shield_fill,
                label: s.security,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const SecurityScreen()),
                ),
              ),
              const _Line(),
              _RowItem(
                icon: CupertinoIcons.globe,
                label: s.language,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const LanguageScreen()),
                ),
              ),
              const _Line(),
              _RowItem(
                icon: CupertinoIcons.question_circle_fill,
                label: s.helpCenter,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const HelpCenterScreen()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          child: _RowItem(
            icon: CupertinoIcons.square_arrow_right,
            label: s.logout,
            danger: true,
            onTap: () => _logout(context, s),
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: _RowItem(
            icon: CupertinoIcons.trash_fill,
            label: s.deleteAccount,
            danger: true,
            onTap: () => _delete(context, s),
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context, dynamic s) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(s.logoutTitle),
        content: Text(s.logoutMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(s.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(s.logout),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context, dynamic s) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(s.deleteAccount),
        content: Text(s.deleteAccountMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(s.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(s.delete),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await AuthService.instance.deleteAccount();
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$e')));
              }
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

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: ZColors.of(context).border, indent: 60);
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _RowItem({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _IconBox(icon: icon, color: color),
            const SizedBox(width: 12),
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

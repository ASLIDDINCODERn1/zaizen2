import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/auth/profile_store.dart';
import 'package:zaizen/core/app_permissions.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/home_hub.dart';
import 'package:zaizen/pages/notifications_inbox.dart';
import 'package:zaizen/pages/profile.dart';
import 'package:zaizen/pages/settings.dart';
import 'package:zaizen/ui/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  final List<Widget> _pages = const [
    _HomeTab(),
    _LeaderboardTab(),
    ProfileTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final dark = context.watch<ThemeProvider>().isDark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: c.bgBottom,
        systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.bgBottom,
        extendBody: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: c.bgBottom,
            gradient: LinearGradient(
              colors: [c.bgTop, c.bgBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: IndexedStack(index: _tabIndex, children: _pages),
          ),
        ),
        bottomNavigationBar: _FloatingNavBar(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final c = ZColors.of(context);
    final pad = MediaQuery.paddingOf(context);
    final bottomInset = pad.bottom > 0 ? pad.bottom + 4 : 14.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        PageGutters.navSide(context),
        0,
        PageGutters.navSide(context),
        bottomInset,
      ),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: c.border.withValues(alpha: 0.35),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavButton(
              icon: currentIndex == 0
                  ? CupertinoIcons.house_fill
                  : CupertinoIcons.house,
              label: s.navHome,
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavButton(
              icon: currentIndex == 1
                  ? CupertinoIcons.chart_bar_fill
                  : CupertinoIcons.chart_bar,
              label: s.navRating,
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavButton(
              icon: currentIndex == 2
                  ? CupertinoIcons.person_fill
                  : CupertinoIcons.person,
              label: s.navProfile,
              active: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavButton(
              icon: currentIndex == 3
                  ? CupertinoIcons.gear_alt_fill
                  : CupertinoIcons.gear,
              label: s.navSettings,
              active: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? c.primary.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 20,
                color: active ? c.primary : c.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? c.primary : c.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmoothCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _SmoothCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border.withValues(alpha: 0.55), width: 0.7),
      ),
      child: child,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  Future<void> _openInbox(BuildContext context) async {
    final ok = await AppPermissions.ensure(
      context,
      AppPermissionKind.notification,
    );
    if (!ok || !context.mounted) return;
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const NotificationsInboxScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final profile = context.watch<ProfileStore>();
    final avatar = profile.avatarUrl;
    final c = ZColors.of(context);
    return ListView(
      padding: PageGutters.of(context),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.primary, width: 1.6),
              ),
              child: ClipOval(
                child: avatar != null && avatar.isNotEmpty
                    ? Image.network(
                        avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(CupertinoIcons.person_fill, color: c.primary),
                      )
                    : Icon(CupertinoIcons.person_fill, color: c.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.welcome,
                    style: TextStyle(color: c.textMuted, fontSize: 13),
                  ),
                  Text(
                    profile.name.isEmpty ? 'User' : profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _IconCircle(
              icon: CupertinoIcons.bell,
              onTap: () => _openInbox(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: CupertinoIcons.star_fill,
                value: '0',
                label: s.score,
                color: c.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: CupertinoIcons.flame_fill,
                value: '0',
                label: s.streak,
                color: c.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: CupertinoIcons.rosette,
                value: '#0',
                label: s.rank,
                color: c.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const HomeHubSection(),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconCircle({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: c.border.withValues(alpha: 0.5),
            width: 0.7,
          ),
        ),
        child: Icon(icon, color: c.primary, size: 19),
      ),
      minimumSize: Size(0, 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return _SmoothCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: c.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final t = hubCopy(context.watch<LocaleProvider>().locale.languageCode);
    final c = ZColors.of(context);
    return ListView(
      padding: PageGutters.of(context),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          s.leaderboardTitle,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          s.leaderboardSub,
          style: TextStyle(color: c.textMuted, fontSize: 13.5),
        ),
        const SizedBox(height: 48),
        Center(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  color: c.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t['boardEmpty']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t['boardHint']!,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textMuted, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

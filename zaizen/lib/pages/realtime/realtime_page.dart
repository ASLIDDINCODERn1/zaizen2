import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/core/app_permissions.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/ui/app_theme.dart';

class RealtimePage extends StatefulWidget {
  const RealtimePage({super.key});

  @override
  State<RealtimePage> createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage>
    with SingleTickerProviderStateMixin {
  bool _micOn = true;
  bool _ready = false;
  late final AnimationController _pulse;

  Map<String, String> _t(String code) {
    switch (code) {
      case 'ru':
        return {
          'live': 'Realtime',
          'on': 'Микрофон включен',
          'off': 'Микрофон выключен',
          'hint': 'Позже здесь будет AI-bot',
        };
      case 'en':
        return {
          'live': 'Realtime',
          'on': 'Microphone on',
          'off': 'Microphone off',
          'hint': 'AI bot will join here later',
        };
      case 'ja':
        return {
          'live': 'Realtime',
          'on': 'マイク ON',
          'off': 'マイク OFF',
          'hint': '後で AI ボットが入ります',
        };
      default:
        return {
          'live': 'Realtime',
          'on': 'Mikrofon yoqilgan',
          'off': "Mikrofon o'chiq",
          'hint': 'Keyin bu yerda AI bot bilan gaplashasiz',
        };
    }
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final ok = await AppPermissions.ensure(
      context,
      AppPermissionKind.microphone,
    );
    if (!mounted) return;
    if (!ok) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _micOn = true;
      _ready = true;
    });
  }

  Future<void> _toggleMic() async {
    if (_micOn) {
      setState(() => _micOn = false);
      return;
    }
    final ok = await AppPermissions.ensure(
      context,
      AppPermissionKind.microphone,
    );
    if (!ok || !mounted) return;
    setState(() => _micOn = true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final t = _t(context.watch<LocaleProvider>().locale.languageCode);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.bgTop, c.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final s = _micOn ? 1.0 + (_pulse.value * 0.08) : 1.0;
                        return Transform.scale(scale: s, child: child);
                      },
                      child: Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_micOn ? c.primary : c.surface).withValues(
                            alpha: 0.18,
                          ),
                          border: Border.all(
                            color: _micOn ? c.primary : c.border,
                            width: 1.4,
                          ),
                        ),
                        child: Icon(
                          _micOn
                              ? CupertinoIcons.mic_fill
                              : CupertinoIcons.mic_slash_fill,
                          color: _micOn ? c.primary : c.textMuted,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Zaizen AI',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      !_ready ? '...' : (_micOn ? t['on']! : t['off']!),
                      style: TextStyle(
                        color: _micOn ? c.primary : c.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t['hint']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoundBtn(
                      icon: CupertinoIcons.xmark,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _micOn
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t['live']!,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        _RoundBtn(
                          icon: CupertinoIcons.gear_alt_fill,
                          active: true,
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: c.surface.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: c.border.withValues(alpha: 0.45),
                            ),
                          ),
                          child: _RoundBtn(
                            icon: _micOn
                                ? CupertinoIcons.mic_fill
                                : CupertinoIcons.mic_slash_fill,
                            active: _micOn,
                            onTap: _toggleMic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _RoundBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

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
          shape: BoxShape.circle,
          color: active ? c.primary : c.surface.withValues(alpha: 0.7),
          border: Border.all(color: c.border.withValues(alpha: 0.45)),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : c.textPrimary,
          size: 18,
        ),
      ),
      minimumSize: Size(0, 0),
    );
  }
}

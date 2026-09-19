import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/core/app_permissions.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/lessons/lessons_path.dart';
import 'package:zaizen/pages/realtime/realtime_page.dart';
import 'package:zaizen/ui/app_theme.dart';

Map<String, String> hubCopy(String code) {
  switch (code) {
    case 'ru':
      return {
        'lessons': 'Уроки',
        'lessonsSub': 'Начать урок',
        'chat': 'Realtime',
        'chatSub': 'Микрофон',
        'dict': 'Словарь',
        'dictSub': 'Слова и кандзи',
        'saved': 'Избранное',
        'savedSub': 'Ваши закладки',
        'boardEmpty': 'Пока пусто',
        'boardHint': 'Рейтинг появится после realtime',
      };
    case 'en':
      return {
        'lessons': 'Lessons',
        'lessonsSub': 'Start a lesson',
        'chat': 'Realtime',
        'chatSub': 'Microphone',
        'dict': 'Dictionary',
        'dictSub': 'Words and kanji',
        'saved': 'Saved',
        'savedSub': 'Your bookmarks',
        'boardEmpty': 'No rankings yet',
        'boardHint': 'Players will appear here in realtime',
      };
    case 'ja':
      return {
        'lessons': 'レッスン',
        'lessonsSub': '学習を始める',
        'chat': 'Realtime',
        'chatSub': 'マイク',
        'dict': '辞書',
        'dictSub': '単語と漢字',
        'saved': '保存',
        'savedSub': 'ブックマーク',
        'boardEmpty': 'まだランキングはありません',
        'boardHint': 'リアルタイムで表示されます',
      };
    default:
      return {
        'lessons': 'Darslar',
        'lessonsSub': 'Darsni boshlash',
        'chat': 'Realtime',
        'chatSub': 'Mikrofon',
        'dict': "Lug'at",
        'dictSub': "So'z va kanji",
        'saved': 'Saqlangan',
        'savedSub': 'Belgilanganlar',
        'boardEmpty': "Hozircha reyting bo'sh",
        'boardHint': "Realtime ulagach, o'yinchilar shu yerda chiqadi",
      };
  }
}

class HomeHubSection extends StatelessWidget {
  const HomeHubSection({super.key});

  Future<void> _openRealtime(BuildContext context) async {
    final ok = await AppPermissions.ensure(context, AppPermissionKind.microphone);
    if (!ok || !context.mounted) return;
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const RealtimePage()));
  }

  void _openLessons(BuildContext context) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const LessonsPathScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final t = hubCopy(context.watch<LocaleProvider>().locale.languageCode);
    return Column(
      children: [
        _FeatureCard(
          icon: CupertinoIcons.square_favorites_alt_fill,
          title: t['lessons']!,
          subtitle: t['lessonsSub']!,
          onTap: () => _openLessons(context),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ChatCard(
                title: t['chat']!,
                subtitle: t['chatSub']!,
                onTap: () => _openRealtime(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniCard(
                icon: CupertinoIcons.textformat,
                title: t['dict']!,
                subtitle: t['dictSub']!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _StripCard(
          icon: CupertinoIcons.bookmark_fill,
          title: t['saved']!,
          subtitle: t['savedSub']!,
        ),
      ],
    );
  }
}

class _Pane extends StatelessWidget {
  final Widget child;
  final double? height;
  final VoidCallback? onTap;
  const _Pane({required this.child, this.height, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final pane = Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.06), width: 0.8),
      ),
      child: child,
    );
    if (onTap == null) return pane;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: pane);
  }
}

class _HubIcon extends StatelessWidget {
  final IconData icon;
  const _HubIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: c.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: c.primary, size: 18),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _FeatureCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return _Pane(
      height: 108,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.primary.withValues(alpha: 0.10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: c.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: c.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_forward, size: 16, color: c.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ChatCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return _Pane(
      height: 118,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                _HubIcon(CupertinoIcons.sparkles),
                SizedBox(width: 6),
                _HubIcon(CupertinoIcons.mic_fill),
              ],
            ),
            const Spacer(),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _MiniCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return _Pane(
      height: 118,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HubIcon(icon),
            const Spacer(),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StripCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _StripCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return _Pane(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            _HubIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.5)),
                  Text(subtitle, style: TextStyle(color: c.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, size: 16, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}

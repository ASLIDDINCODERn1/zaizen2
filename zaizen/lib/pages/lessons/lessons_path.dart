import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/lessons/lesson_session.dart';
import 'package:zaizen/ui/app_theme.dart';

enum LessonNodeStatus { done, current, locked }

class _Node {
  final LessonNodeStatus status;
  final IconData icon;
  final double drift;
  const _Node({required this.status, required this.icon, required this.drift});
}

Map<String, String> _copy(String code) {
  switch (code) {
    case 'ru':
      return {
        'title': 'Уроки',
        'section': 'Раздел 1 · Юнит 1',
        'unit': 'Основы хираганы',
        'start': 'Начать',
        'locked': 'Сначала текущий урок',
      };
    case 'en':
      return {
        'title': 'Lessons',
        'section': 'Section 1 · Unit 1',
        'unit': 'Hiragana basics',
        'start': 'Start',
        'locked': 'Finish the current lesson first',
      };
    case 'ja':
      return {
        'title': 'レッスン',
        'section': 'セクション 1 · ユニット 1',
        'unit': 'ひらがなの基礎',
        'start': 'スタート',
        'locked': '先に現在のレッスンを',
      };
    default:
      return {
        'title': 'Darslar',
        'section': "Bo'lim 1 · Dars 1",
        'unit': 'Hiragana asoslari',
        'start': 'Boshlash',
        'locked': 'Avval joriy darsni tugating',
      };
  }
}

class LessonsPathScreen extends StatelessWidget {
  const LessonsPathScreen({super.key});

  static const _nodes = <_Node>[
    _Node(status: LessonNodeStatus.done, icon: CupertinoIcons.checkmark_alt, drift: 0),
    _Node(status: LessonNodeStatus.current, icon: CupertinoIcons.star_fill, drift: 46),
    _Node(status: LessonNodeStatus.locked, icon: CupertinoIcons.lock_fill, drift: -38),
    _Node(status: LessonNodeStatus.locked, icon: CupertinoIcons.book_fill, drift: 22),
    _Node(status: LessonNodeStatus.locked, icon: CupertinoIcons.lock_fill, drift: -48),
    _Node(status: LessonNodeStatus.locked, icon: CupertinoIcons.headphones, drift: 8),
    _Node(status: LessonNodeStatus.locked, icon: CupertinoIcons.gift_fill, drift: 40),
  ];

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final t = _copy(context.watch<LocaleProvider>().locale.languageCode);
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () => Navigator.pop(context),
                      child: Icon(CupertinoIcons.chevron_back, color: c.textPrimary, size: 22),
                    ),
                    const SizedBox(width: 4),
                    Text(t['title']!, style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: c.surface.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.primary.withValues(alpha: 0.35), width: 0.9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['section']!, style: TextStyle(color: c.primary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                      const SizedBox(height: 4),
                      Text(t['unit']!, style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _nodes.length,
                  itemBuilder: (context, i) {
                    final node = _nodes[i];
                    return _PathRow(
                      node: node,
                      startLabel: t['start']!,
                      lockedHint: t['locked']!,
                      showStem: i != _nodes.length - 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  final _Node node;
  final String startLabel;
  final String lockedHint;
  final bool showStem;
  const _PathRow({
    required this.node,
    required this.startLabel,
    required this.lockedHint,
    required this.showStem,
  });

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final current = node.status == LessonNodeStatus.current;
    final done = node.status == LessonNodeStatus.done;
    final size = current ? 84.0 : 68.0;
    final fill = done || current ? c.primary : c.surface;
    final iconColor = done || current ? Colors.white : c.textMuted;

    return SizedBox(
      height: current ? 138 : 108,
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(node.drift, 0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (node.status == LessonNodeStatus.current) {
                      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const LessonSessionScreen()));
                      return;
                    }
                    if (node.status == LessonNodeStatus.locked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lockedHint),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: c.surface,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fill,
                      border: Border.all(
                        color: current ? Colors.white.withValues(alpha: 0.28) : c.border.withValues(alpha: 0.7),
                        width: current ? 3 : 1,
                      ),
                      boxShadow: current
                          ? [BoxShadow(color: c.primary.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))]
                          : null,
                    ),
                    child: Icon(node.icon, color: iconColor, size: current ? 30 : 22),
                  ),
                ),
                if (current) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(startLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.4)),
                  ),
                ],
              ],
            ),
          ),
          if (showStem)
            Expanded(
              child: Transform.translate(
                offset: Offset(node.drift, 0),
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: (done || current) ? c.primary.withValues(alpha: 0.45) : c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

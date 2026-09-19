import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/ui/app_theme.dart';

class LessonSessionScreen extends StatefulWidget {
  const LessonSessionScreen({super.key});

  @override
  State<LessonSessionScreen> createState() => _LessonSessionScreenState();
}

class _LessonSessionScreenState extends State<LessonSessionScreen> {
  int? _picked;
  bool _checked = false;
  static const _correct = 0;
  static const _options = ['a', 'i', 'u', 'e'];

  Map<String, String> _t(String code) {
    switch (code) {
      case 'ru':
        return {'ask': 'Как читается?', 'check': 'Проверить', 'next': 'Далее', 'ok': 'Верно', 'no': 'Неверно'};
      case 'en':
        return {'ask': 'How is this read?', 'check': 'Check', 'next': 'Continue', 'ok': 'Correct', 'no': 'Not quite'};
      case 'ja':
        return {'ask': 'これはなんと読みますか？', 'check': '確認', 'next': '次へ', 'ok': '正しい', 'no': '違います'};
      default:
        return {'ask': "Bu qanday o'qiladi?", 'check': 'Tekshirish', 'next': 'Davom etish', 'ok': "To'g'ri", 'no': "Noto'g'ri"};
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final t = _t(context.watch<LocaleProvider>().locale.languageCode);
    final canCheck = _picked != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c.bgTop, c.bgBottom], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Icon(CupertinoIcons.xmark, color: c.textPrimary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.18,
                          minHeight: 8,
                          backgroundColor: c.border,
                          valueColor: AlwaysStoppedAnimation(c.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(t['ask']!, style: TextStyle(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 22),
                Container(
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: c.border.withValues(alpha: 0.7)),
                  ),
                  child: Text('あ', style: TextStyle(color: c.textPrimary, fontSize: 72, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 22),
                for (var i = 0; i < _options.length; i++) ...[
                  _Choice(
                    label: _options[i],
                    selected: _picked == i,
                    correct: _checked && i == _correct,
                    wrong: _checked && _picked == i && i != _correct,
                    onTap: _checked ? null : () => setState(() => _picked = i),
                  ),
                  const SizedBox(height: 10),
                ],
                const Spacer(),
                if (_checked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _picked == _correct ? t['ok']! : t['no']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _picked == _correct ? c.primary : c.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: !canCheck
                      ? null
                      : () {
                          if (!_checked) {
                            setState(() => _checked = true);
                            return;
                          }
                          Navigator.pop(context);
                        },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: canCheck ? c.primary : c.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _checked ? t['next']! : t['check']!,
                      style: TextStyle(
                        color: canCheck ? Colors.white : c.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;
  const _Choice({required this.label, required this.selected, required this.correct, required this.wrong, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final border = correct
        ? c.primary
        : wrong
            ? c.danger
            : selected
                ? c.primary
                : c.border;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: selected || correct || wrong ? 1.4 : 0.8),
        ),
        child: Text(label, style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

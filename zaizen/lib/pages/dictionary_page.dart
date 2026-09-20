import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/dictionary/dictionary_api.dart';
import 'package:zaizen/pages/dictionary/dictionary_models.dart';
import 'package:zaizen/pages/dictionary/dictionary_store.dart';
import 'package:zaizen/ui/app_theme.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final _searchController = TextEditingController();
  final _focus = FocusNode();
  final _store = DictionaryStore();
  Timer? _debounce;
  String _filter = 'all';
  bool _loading = false;
  bool _ready = false;
  String? _error;
  String _lastQuery = '';
  List<DictWord> _results = [];

  static const _starters = [
    'こんにちは',
    'ありがとう',
    '食べる',
    '水',
    '日本',
    'hello',
    'study',
    'friend',
    'sensei',
    'salom',
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _store.load();
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focus.dispose();
    super.dispose();
  }

  Map<String, String> get _t {
    final code = context.read<LocaleProvider>().locale.languageCode;
    switch (code) {
      case 'ru':
        return {
          'title': 'Словарь',
          'hint': 'Любое слово: японский, английский, узбекский…',
          'all': 'Все',
          'common': 'Частые',
          'n5': 'N5',
          'n4': 'N4',
          'n3': 'N3',
          'saved': 'Избранное',
          'recent': 'Недавние',
          'suggest': 'Попробуйте',
          'empty': 'Ничего не найдено',
          'emptyHint': 'Напишите любое слово — словарь ищет в реальном JMDict.',
          'loading': 'Ищем…',
          'meanings': 'Значения',
          'kanji': 'Кандзи',
          'forms': 'Формы',
          'commonBadge': 'частое',
          'savedOk': 'Сохранено',
          'copied': 'Скопировано',
          'error': 'Сеть недоступна. Проверьте интернет.',
          'count': 'слов',
          'browse': 'Напишите слово',
          'browseHint': 'こんにちは, salom, вода, eat — что угодно.',
          'noSaved': 'Пока пусто',
          'noSavedHint': 'Нажмите закладку у слова, чтобы сохранить.',
          'from': 'Искали как',
          'strokes': 'черт',
        };
      case 'en':
        return {
          'title': 'Dictionary',
          'hint': 'Any word: Japanese, English, Uzbek…',
          'all': 'All',
          'common': 'Common',
          'n5': 'N5',
          'n4': 'N4',
          'n3': 'N3',
          'saved': 'Saved',
          'recent': 'Recent',
          'suggest': 'Try',
          'empty': 'No matches',
          'emptyHint': 'Type any word — live lookup in JMDict.',
          'loading': 'Searching…',
          'meanings': 'Meanings',
          'kanji': 'Kanji',
          'forms': 'Forms',
          'commonBadge': 'common',
          'savedOk': 'Saved',
          'copied': 'Copied',
          'error': 'Could not reach the dictionary. Check the network.',
          'count': 'words',
          'browse': 'Look up a word',
          'browseHint': 'こんにちは, hello, salom, eat — anything works.',
          'noSaved': 'Nothing saved yet',
          'noSavedHint': 'Tap the bookmark on a word to keep it.',
          'from': 'Looked up as',
          'strokes': 'strokes',
        };
      case 'ja':
        return {
          'title': '辞書',
          'hint': '日本語・英語・ウズベク語… 好きな単語を入力',
          'all': 'すべて',
          'common': 'よく使う',
          'n5': 'N5',
          'n4': 'N4',
          'n3': 'N3',
          'saved': '保存',
          'recent': '最近',
          'suggest': '試す',
          'empty': '見つかりません',
          'emptyHint': 'どんな単語でも検索できます。',
          'loading': '検索中…',
          'meanings': '意味',
          'kanji': '漢字',
          'forms': '表記',
          'commonBadge': '常用',
          'savedOk': '保存しました',
          'copied': 'コピーしました',
          'error': '接続できません。通信を確認してください。',
          'count': '語',
          'browse': '単語を調べる',
          'browseHint': 'こんにちは、hello、salom — 何でも大丈夫。',
          'noSaved': 'まだありません',
          'noSavedHint': 'ブックマークで保存できます。',
          'from': '検索語',
          'strokes': '画',
        };
      default:
        return {
          'title': "Lug'at",
          'hint': "Istalgan so'z: yapon, ingliz, o'zbek…",
          'all': 'Hammasi',
          'common': 'Ko‘p ishlatiladi',
          'n5': 'N5',
          'n4': 'N4',
          'n3': 'N3',
          'saved': 'Saqlangan',
          'recent': 'Yaqinda',
          'suggest': 'Sinab ko‘ring',
          'empty': 'Topilmadi',
          'emptyHint': "Istalgan so'zni yozing — jonli JMDict qidiruvi.",
          'loading': 'Qidirilmoqda…',
          'meanings': 'Ma’nolar',
          'kanji': 'Kanji',
          'forms': 'Shakllar',
          'commonBadge': 'keng tarqalgan',
          'savedOk': 'Saqlandi',
          'copied': 'Nusxalandi',
          'error': "Lug'atga ulanib bo'lmadi. Internetni tekshiring.",
          'count': "so'z",
          'browse': "So'z qidiring",
          'browseHint': 'こんにちは, salom, hello, eat — hammasi ishlaydi.',
          'noSaved': "Hozircha bo'sh",
          'noSavedHint': "So'z yonidagi xatcho‘pni bosing.",
          'from': 'Qidiruv',
          'strokes': 'chiziq',
        };
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
        _error = null;
        _lastQuery = '';
        if (_filter == 'saved') return;
        _filter = 'all';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 380), () => _runSearch(q));
  }

  Future<void> _runSearch(String q, {bool record = true}) async {
    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = q;
      if (_filter == 'saved') _filter = 'all';
    });
    final lang = context.read<LocaleProvider>().locale.languageCode;
    final results = await DictionaryApi.search(q, uiLang: lang);
    if (!mounted) return;
    if (record) await _store.addRecent(q);
    setState(() {
      _results = results;
      _loading = false;
      if (results.isEmpty && q.isNotEmpty) {
        _error = null;
      }
    });
  }

  List<DictWord> get _visible {
    if (_filter == 'saved') return _store.favorites;
    Iterable<DictWord> list = _results;
    switch (_filter) {
      case 'common':
        list = list.where((w) => w.isCommon);
      case 'n5':
        list = list.where((w) => w.jlpt.any((j) => j.contains('n5')));
      case 'n4':
        list = list.where((w) => w.jlpt.any((j) => j.contains('n4')));
      case 'n3':
        list = list.where((w) => w.jlpt.any((j) => j.contains('n3')));
    }
    return list.toList();
  }

  void _toast(String text) {
    final c = ZColors.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  Future<void> _openWord(DictWord word) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WordSheet(
        word: word,
        store: _store,
        t: _t,
        onChanged: () => setState(() {}),
        onToast: _toast,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = ZColors.of(context);
    final t = _t;
    final visible = _visible;
    final browsing = _searchController.text.trim().isEmpty && _filter != 'saved';

    return Scaffold(
      backgroundColor: colors.bgTop,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.bgTop, colors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.chevron_back,
                        color: colors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        t['title']!,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'JMDict',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focus,
                  onChanged: _onQueryChanged,
                  onSubmitted: (v) {
                    _debounce?.cancel();
                    _runSearch(v.trim());
                  },
                  textInputAction: TextInputAction.search,
                  style: TextStyle(color: colors.textPrimary, fontSize: 16),
                  cursorColor: colors.primary,
                  decoration: InputDecoration(
                    hintText: t['hint'],
                    hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: colors.primary,
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(
                              CupertinoIcons.clear_circled_solid,
                              color: colors.textMuted,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onQueryChanged('');
                              _focus.requestFocus();
                            },
                          ),
                    filled: true,
                    fillColor: colors.surface.withValues(alpha: 0.92),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: colors.border.withValues(alpha: 0.55),
                        width: 0.7,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: colors.primary, width: 1.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _Chip(
                      label: t['all']!,
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    _Chip(
                      label: t['common']!,
                      selected: _filter == 'common',
                      onTap: () => setState(() => _filter = 'common'),
                    ),
                    _Chip(
                      label: t['n5']!,
                      selected: _filter == 'n5',
                      onTap: () => setState(() => _filter = 'n5'),
                    ),
                    _Chip(
                      label: t['n4']!,
                      selected: _filter == 'n4',
                      onTap: () => setState(() => _filter = 'n4'),
                    ),
                    _Chip(
                      label: t['n3']!,
                      selected: _filter == 'n3',
                      onTap: () => setState(() => _filter = 'n3'),
                    ),
                    _Chip(
                      label: t['saved']!,
                      selected: _filter == 'saved',
                      onTap: () => setState(() => _filter = 'saved'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: !_ready
                    ? Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      )
                    : _loading
                        ? _LoadingState(colors: colors, label: t['loading']!)
                        : browsing
                            ? _BrowseState(
                                colors: colors,
                                t: t,
                                recents: _store.recents,
                                starters: _starters,
                                onPick: (q) {
                                  _searchController.text = q;
                                  _searchController.selection =
                                      TextSelection.collapsed(offset: q.length);
                                  _runSearch(q);
                                },
                              )
                            : visible.isEmpty
                                ? _EmptyState(
                                    colors: colors,
                                    title: _filter == 'saved'
                                        ? t['noSaved']!
                                        : t['empty']!,
                                    hint: _filter == 'saved'
                                        ? t['noSavedHint']!
                                        : t['emptyHint']!,
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      28,
                                    ),
                                    itemCount: visible.length + 1,
                                    itemBuilder: (context, i) {
                                      if (i == 0) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Text(
                                            '${visible.length} ${t['count']}',
                                            style: TextStyle(
                                              color: colors.textMuted,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }
                                      final word = visible[i - 1];
                                      return _WordCard(
                                        word: word,
                                        colors: colors,
                                        saved: _store.isSaved(word),
                                        commonLabel: t['commonBadge']!,
                                        onOpen: () => _openWord(word),
                                        onSave: () async {
                                          await _store.toggleFavorite(word);
                                          setState(() {});
                                          _toast(
                                            _store.isSaved(word)
                                                ? t['savedOk']!
                                                : t['title']!,
                                          );
                                        },
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

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? c.primary.withValues(alpha: 0.18)
                : c.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? c.primary.withValues(alpha: 0.55)
                  : c.border.withValues(alpha: 0.5),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? c.primary : c.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final DictWord word;
  final ZColors colors;
  final bool saved;
  final String commonLabel;
  final VoidCallback onOpen;
  final VoidCallback onSave;

  const _WordCard({
    required this.word,
    required this.colors,
    required this.saved,
    required this.commonLabel,
    required this.onOpen,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.55),
                width: 0.7,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (word.reading.isNotEmpty &&
                              word.reading != word.word)
                            word.reading,
                          if (word.romaji.isNotEmpty) word.romaji,
                        ].join('  ·  '),
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word.meanings.take(3).join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (word.isCommon) _Pill(commonLabel, colors),
                          if (word.jlptLabel.isNotEmpty)
                            _Pill(word.jlptLabel, colors, accent: true),
                          if (word.primaryPos.isNotEmpty)
                            _Pill(word.primaryPos, colors),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    saved
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    color: saved ? colors.primary : colors.textMuted,
                    size: 20,
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

class _Pill extends StatelessWidget {
  final String text;
  final ZColors colors;
  final bool accent;
  const _Pill(this.text, this.colors, {this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent
            ? colors.primary.withValues(alpha: 0.16)
            : colors.border.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent ? colors.primary : colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BrowseState extends StatelessWidget {
  final ZColors colors;
  final Map<String, String> t;
  final List<String> recents;
  final List<String> starters;
  final ValueChanged<String> onPick;

  const _BrowseState({
    required this.colors,
    required this.t,
    required this.recents,
    required this.starters,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.5),
              width: 0.7,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CupertinoIcons.book_fill,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                t['browse']!,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t['browseHint']!,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (recents.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            t['recent']!,
            style: TextStyle(
              color: colors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recents
                .map((q) => _SuggestChip(label: q, onTap: () => onPick(q)))
                .toList(),
          ),
        ],
        const SizedBox(height: 22),
        Text(
          t['suggest']!,
          style: TextStyle(
            color: colors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: starters
              .map((q) => _SuggestChip(label: q, onTap: () => onPick(q)))
              .toList(),
        ),
      ],
    );
  }
}

class _SuggestChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border.withValues(alpha: 0.55), width: 0.7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ZColors colors;
  final String title;
  final String hint;
  const _EmptyState({
    required this.colors,
    required this.title,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.search,
                color: colors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final ZColors colors;
  final String label;
  const _LoadingState({required this.colors, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(label, style: TextStyle(color: colors.textMuted)),
        ],
      ),
    );
  }
}

class _WordSheet extends StatefulWidget {
  final DictWord word;
  final DictionaryStore store;
  final Map<String, String> t;
  final VoidCallback onChanged;
  final void Function(String) onToast;

  const _WordSheet({
    required this.word,
    required this.store,
    required this.t,
    required this.onChanged,
    required this.onToast,
  });

  @override
  State<_WordSheet> createState() => _WordSheetState();
}

class _WordSheetState extends State<_WordSheet> {
  List<KanjiInfo> _kanji = [];
  bool _kanjiLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKanji();
  }

  Future<void> _loadKanji() async {
    final chars = widget.word.word.runes
        .map(String.fromCharCode)
        .where((ch) => RegExp(r'[\u4e00-\u9fff]').hasMatch(ch))
        .toSet();
    final out = <KanjiInfo>[];
    for (final ch in chars.take(6)) {
      final info = await DictionaryApi.kanji(ch);
      if (info != null) out.add(info);
    }
    if (mounted) {
      setState(() {
        _kanji = out;
        _kanjiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final word = widget.word;
    final saved = widget.store.isSaved(word);
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: c.bgBottom,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: c.border.withValues(alpha: 0.4), width: 0.6),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.word,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: word.word));
                        widget.onToast(widget.t['copied']!);
                      },
                      icon: Icon(CupertinoIcons.doc_on_doc, color: c.textMuted),
                    ),
                    IconButton(
                      onPressed: () async {
                        await widget.store.toggleFavorite(word);
                        widget.onChanged();
                        setState(() {});
                        widget.onToast(
                          widget.store.isSaved(word)
                              ? widget.t['savedOk']!
                              : widget.t['title']!,
                        );
                      },
                      icon: Icon(
                        saved
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        color: saved ? c.primary : c.textMuted,
                      ),
                    ),
                  ],
                ),
                if (word.reading.isNotEmpty)
                  Text(
                    word.reading,
                    style: TextStyle(
                      color: c.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (word.romaji.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      word.romaji,
                      style: TextStyle(color: c.textMuted, fontSize: 14),
                    ),
                  ),
                if (word.translatedFrom != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${widget.t['from']}: ${word.translatedFrom}',
                      style: TextStyle(color: c.textMuted, fontSize: 12.5),
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (word.isCommon)
                      _Pill(widget.t['commonBadge']!, c, accent: true),
                    if (word.jlptLabel.isNotEmpty)
                      _Pill(word.jlptLabel, c, accent: true),
                    ...word.partsOfSpeech.take(4).map((p) => _Pill(p, c)),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  widget.t['meanings']!,
                  style: TextStyle(
                    color: c.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                ...word.senses.take(8).toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final sense = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: c.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (sense.partsOfSpeech.isNotEmpty)
                                Text(
                                  sense.partsOfSpeech.join(' · '),
                                  style: TextStyle(
                                    color: c.primary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                sense.definitions.join('; '),
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 15.5,
                                  height: 1.35,
                                ),
                              ),
                              if (sense.tags.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    sense.tags.join(' · '),
                                    style: TextStyle(
                                      color: c.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (word.forms.length > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.t['forms']!,
                    style: TextStyle(
                      color: c.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: word.forms
                        .map(
                          (f) => _Pill(
                            f.reading.isEmpty
                                ? f.word
                                : '${f.word} (${f.reading})',
                            c,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (_kanjiLoading || _kanji.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    widget.t['kanji']!,
                    style: TextStyle(
                      color: c.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_kanjiLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: c.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._kanji.map(
                      (k) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: c.border.withValues(alpha: 0.5),
                            width: 0.7,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              k.kanji,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    k.meaning,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      if (k.onyomi.isNotEmpty)
                                        'on ${k.onyomi.take(3).join(' ')}',
                                      if (k.kunyomi.isNotEmpty)
                                        'kun ${k.kunyomi.take(3).join(' ')}',
                                      if (k.strokeCount > 0)
                                        '${k.strokeCount} ${widget.t['strokes']}',
                                      if (k.jlpt.isNotEmpty) k.jlpt,
                                    ].join('  ·  '),
                                    style: TextStyle(
                                      color: c.textMuted,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

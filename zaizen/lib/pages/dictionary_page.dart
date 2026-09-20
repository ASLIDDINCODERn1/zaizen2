import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zaizen/ui/app_theme.dart';

class DictionaryEntry {
  final String japanese;
  final String reading;
  final String meaning;
  final String example;
  final String category;

  const DictionaryEntry({
    required this.japanese,
    required this.reading,
    required this.meaning,
    required this.example,
    required this.category,
  });
}

const _entries = <DictionaryEntry>[
  DictionaryEntry(
    japanese: 'こんにちは',
    reading: 'konnichiwa',
    meaning: 'hello',
    example: 'こんにちは。お元気ですか？',
    category: 'Basics',
  ),
  DictionaryEntry(
    japanese: 'ありがとう',
    reading: 'arigatou',
    meaning: 'thank you',
    example: '手伝ってくれてありがとう。',
    category: 'Basics',
  ),
  DictionaryEntry(
    japanese: '勉強',
    reading: 'benkyou',
    meaning: 'study; learning',
    example: '毎日日本語を勉強します。',
    category: 'Study',
  ),
  DictionaryEntry(
    japanese: '先生',
    reading: 'sensei',
    meaning: 'teacher',
    example: '先生に質問があります。',
    category: 'People',
  ),
  DictionaryEntry(
    japanese: '友達',
    reading: 'tomodachi',
    meaning: 'friend',
    example: '友達と映画を見ました。',
    category: 'People',
  ),
  DictionaryEntry(
    japanese: '食べる',
    reading: 'taberu',
    meaning: 'to eat',
    example: '朝ごはんを食べます。',
    category: 'Verbs',
  ),
  DictionaryEntry(
    japanese: '見る',
    reading: 'miru',
    meaning: 'to see; to watch',
    example: '週末に映画を見ます。',
    category: 'Verbs',
  ),
  DictionaryEntry(
    japanese: '大切',
    reading: 'taisetsu',
    meaning: 'important; precious',
    example: '家族は私にとって大切です。',
    category: 'Adjectives',
  ),
];

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final _searchController = TextEditingController();
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DictionaryEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesCategory = _category == 'All' || entry.category == _category;
      final matchesQuery =
          query.isEmpty ||
          entry.japanese.toLowerCase().contains(query) ||
          entry.reading.toLowerCase().contains(query) ||
          entry.meaning.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ZColors.of(context);
    final categories = [
      'All',
      ..._entries.map((entry) => entry.category).toSet(),
    ];
    final entries = _filteredEntries;

    return Scaffold(
      backgroundColor: colors.bgTop,
      appBar: AppBar(
        title: const Text('Dictionary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search Japanese, reading, or meaning',
                prefixIcon: const Icon(CupertinoIcons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled_solid),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${entries.length} ${entries.length == 1 ? 'word' : 'words'}',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 72),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 42,
                      color: colors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No words found',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try another search or category.',
                      style: TextStyle(color: colors.textMuted),
                    ),
                  ],
                ),
              )
            else
              ...entries.map(
                (entry) => _EntryTile(entry: entry, colors: colors),
              ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final DictionaryEntry entry;
  final ZColors colors;

  const _EntryTile({required this.entry, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: colors.surface,
      elevation: 0,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          entry.japanese,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${entry.reading}  •  ${entry.meaning}',
            style: TextStyle(color: colors.textMuted),
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              entry.example,
              style: TextStyle(color: colors.textPrimary, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

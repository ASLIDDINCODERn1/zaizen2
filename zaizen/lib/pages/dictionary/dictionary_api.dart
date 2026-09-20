import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zaizen/pages/dictionary/dictionary_models.dart';

class DictionaryApi {
  static const _jisho = 'https://jisho.org/api/v1/search/words';
  static const _kanji = 'https://kanjiapi.dev/v1/kanji';
  static const _translate = 'https://api.mymemory.translated.net/get';

  static Future<List<DictWord>> search(
    String query, {
    String uiLang = 'en',
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    var results = await _jishoSearch(q);
    if (results.isNotEmpty) return results;

    if (!_looksJapanese(q)) {
      final english = await _toEnglish(q, uiLang);
      if (english != null &&
          english.isNotEmpty &&
          english.toLowerCase() != q.toLowerCase()) {
        results = await _jishoSearch(english);
        for (final word in results) {
          word.translatedFrom = '$q → $english';
        }
      }
    }
    return results;
  }

  static Future<KanjiInfo?> kanji(String character) async {
    if (character.isEmpty) return null;
    final ch = String.fromCharCode(character.runes.first);
    try {
      final res = await http
          .get(Uri.parse('$_kanji/${Uri.encodeComponent(ch)}'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      if (data is! Map) return null;
      final map = Map<String, dynamic>.from(data);
      if (map['error'] != null) return null;
      return KanjiInfo(
        kanji: map['kanji'] as String? ?? ch,
        meaning: (map['meanings'] as List? ?? []).join(', '),
        onyomi: (map['on_readings'] as List? ?? []).cast<String>(),
        kunyomi: (map['kun_readings'] as List? ?? []).cast<String>(),
        strokeCount: map['stroke_count'] as int? ?? 0,
        jlpt: map['jlpt'] == null ? '' : 'N${map['jlpt']}',
        grade: map['grade'] as int?,
        kunyomiExamples: const [],
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<DictWord>> _jishoSearch(String q) async {
    try {
      final uri = Uri.parse(_jisho).replace(queryParameters: {'keyword': q});
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(res.body);
      if (body is! Map) return const [];
      final data = body['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((raw) => _parseJisho(Map<String, dynamic>.from(raw)))
          .whereType<DictWord>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static DictWord? _parseJisho(Map<String, dynamic> raw) {
    final japanese = (raw['japanese'] as List? ?? []).whereType<Map>().toList();
    if (japanese.isEmpty) return null;
    final head = Map<String, dynamic>.from(japanese.first);
    final word = (head['word'] as String?) ?? (head['reading'] as String?) ?? '';
    final reading = (head['reading'] as String?) ?? word;
    if (word.isEmpty) return null;

    final senses = <DictSense>[];
    final meanings = <String>[];
    final pos = <String>{};
    for (final s in (raw['senses'] as List? ?? []).whereType<Map>()) {
      final map = Map<String, dynamic>.from(s);
      final defs = (map['english_definitions'] as List? ?? []).cast<String>();
      final parts = (map['parts_of_speech'] as List? ?? []).cast<String>();
      final tags = [
        ...(map['tags'] as List? ?? []).cast<String>(),
        ...(map['info'] as List? ?? []).cast<String>(),
      ];
      senses.add(
        DictSense(
          definitions: defs,
          partsOfSpeech: parts,
          tags: tags,
          seeAlso: (map['see_also'] as List? ?? []).cast<String>(),
          info: (map['restrictions'] as List? ?? []).cast<String>(),
        ),
      );
      meanings.addAll(defs);
      pos.addAll(parts);
    }

    final forms = japanese.map((j) {
      final m = Map<String, dynamic>.from(j);
      return DictForm(
        word: (m['word'] as String?) ?? (m['reading'] as String?) ?? '',
        reading: (m['reading'] as String?) ?? '',
      );
    }).toList();

    return DictWord(
      id: (raw['slug'] as String?) ?? '$word|$reading',
      word: word,
      reading: reading,
      romaji: _toRomaji(reading),
      meanings: meanings.take(8).toList(),
      partsOfSpeech: pos.toList(),
      jlpt: (raw['jlpt'] as List? ?? []).cast<String>(),
      isCommon: raw['is_common'] == true,
      senses: senses,
      forms: forms,
    );
  }

  static Future<String?> _toEnglish(String q, String uiLang) async {
    final pair = switch (uiLang) {
      'ru' => 'ru|en',
      'uz' => 'uz-UZ|en',
      'ja' => 'ja|en',
      _ => 'autodetect|en',
    };
    try {
      final uri = Uri.parse(_translate).replace(
        queryParameters: {'q': q, 'langpair': pair},
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      if (body is! Map) return null;
      final translated =
          (body['responseData'] as Map?)?['translatedText'] as String?;
      if (translated == null) return null;
      final cleaned =
          translated.replaceAll(RegExp(r'\s*\(.*?\)\s*'), ' ').trim();
      if (cleaned.toLowerCase().contains('invalid') ||
          cleaned.toLowerCase().contains('query length')) {
        return null;
      }
      return cleaned;
    } catch (_) {
      return null;
    }
  }

  static bool _looksJapanese(String q) {
    return RegExp(r'[\u3040-\u30ff\u3400-\u9fff]').hasMatch(q);
  }

  static String _toRomaji(String kana) {
    const map = <String, String>{
      'きゃ': 'kya', 'きゅ': 'kyu', 'きょ': 'kyo',
      'しゃ': 'sha', 'しゅ': 'shu', 'しょ': 'sho',
      'ちゃ': 'cha', 'ちゅ': 'chu', 'ちょ': 'cho',
      'にゃ': 'nya', 'にゅ': 'nyu', 'にょ': 'nyo',
      'ひゃ': 'hya', 'ひゅ': 'hyu', 'ひょ': 'hyo',
      'みゃ': 'mya', 'みゅ': 'myu', 'みょ': 'myo',
      'りゃ': 'rya', 'りゅ': 'ryu', 'りょ': 'ryo',
      'ぎゃ': 'gya', 'ぎゅ': 'gyu', 'ぎょ': 'gyo',
      'じゃ': 'ja', 'じゅ': 'ju', 'じょ': 'jo',
      'びゃ': 'bya', 'びゅ': 'byu', 'びょ': 'byo',
      'ぴゃ': 'pya', 'ぴゅ': 'pyu', 'ぴょ': 'pyo',
      'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
      'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
      'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
      'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
      'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
      'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
      'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
      'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
      'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
      'わ': 'wa', 'を': 'o', 'ん': 'n',
      'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
      'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
      'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
      'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
      'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
      'っ': '', 'ぁ': 'a', 'ぃ': 'i', 'ぅ': 'u', 'ぇ': 'e', 'ぉ': 'o',
      'ゃ': 'ya', 'ゅ': 'yu', 'ょ': 'yo', 'ー': '',
      'ア': 'a', 'イ': 'i', 'ウ': 'u', 'エ': 'e', 'オ': 'o',
      'カ': 'ka', 'キ': 'ki', 'ク': 'ku', 'ケ': 'ke', 'コ': 'ko',
      'サ': 'sa', 'シ': 'shi', 'ス': 'su', 'セ': 'se', 'ソ': 'so',
      'タ': 'ta', 'チ': 'chi', 'ツ': 'tsu', 'テ': 'te', 'ト': 'to',
      'ナ': 'na', 'ニ': 'ni', 'ヌ': 'nu', 'ネ': 'ne', 'ノ': 'no',
      'ハ': 'ha', 'ヒ': 'hi', 'フ': 'fu', 'ヘ': 'he', 'ホ': 'ho',
      'マ': 'ma', 'ミ': 'mi', 'ム': 'mu', 'メ': 'me', 'モ': 'mo',
      'ヤ': 'ya', 'ユ': 'yu', 'ヨ': 'yo',
      'ラ': 'ra', 'リ': 'ri', 'ル': 'ru', 'レ': 're', 'ロ': 'ro',
      'ワ': 'wa', 'ヲ': 'o', 'ン': 'n',
      'ガ': 'ga', 'ギ': 'gi', 'グ': 'gu', 'ゲ': 'ge', 'ゴ': 'go',
      'ザ': 'za', 'ジ': 'ji', 'ズ': 'zu', 'ゼ': 'ze', 'ゾ': 'zo',
      'ダ': 'da', 'ヂ': 'ji', 'ヅ': 'zu', 'デ': 'de', 'ド': 'do',
      'バ': 'ba', 'ビ': 'bi', 'ブ': 'bu', 'ベ': 'be', 'ボ': 'bo',
      'パ': 'pa', 'ピ': 'pi', 'プ': 'pu', 'ペ': 'pe', 'ポ': 'po',
      'ャ': 'ya', 'ュ': 'yu', 'ョ': 'yo', 'ッ': '',
      'キャ': 'kya', 'キュ': 'kyu', 'キョ': 'kyo',
      'シャ': 'sha', 'シュ': 'shu', 'ショ': 'sho',
      'チャ': 'cha', 'チュ': 'chu', 'チョ': 'cho',
      'ニャ': 'nya', 'ニュ': 'nyu', 'ニョ': 'nyo',
      'ヒャ': 'hya', 'ヒュ': 'hyu', 'ヒョ': 'hyo',
      'ミャ': 'mya', 'ミュ': 'myu', 'ミョ': 'myo',
      'リャ': 'rya', 'リュ': 'ryu', 'リョ': 'ryo',
      'ギャ': 'gya', 'ギュ': 'gyu', 'ギョ': 'gyo',
      'ジャ': 'ja', 'ジュ': 'ju', 'ジョ': 'jo',
      'ビャ': 'bya', 'ビュ': 'byu', 'ビョ': 'byo',
      'ピャ': 'pya', 'ピュ': 'pyu', 'ピョ': 'pyo',
    };
    final buf = StringBuffer();
    var i = 0;
    while (i < kana.length) {
      if (i + 1 < kana.length) {
        final pair = kana.substring(i, i + 2);
        if (map.containsKey(pair)) {
          buf.write(map[pair]);
          i += 2;
          continue;
        }
      }
      final ch = kana[i];
      if (ch == 'っ' || ch == 'ッ') {
        if (i + 1 < kana.length) {
          final next = map[kana[i + 1]] ?? kana[i + 1];
          if (next.isNotEmpty) buf.write(next[0]);
        }
        i += 1;
        continue;
      }
      buf.write(map[ch] ?? ch);
      i += 1;
    }
    return buf.toString();
  }
}

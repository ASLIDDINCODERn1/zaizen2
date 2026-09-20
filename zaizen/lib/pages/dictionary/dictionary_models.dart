class DictWord {
  final String id;
  final String word;
  final String reading;
  final String romaji;
  final List<String> meanings;
  final List<String> partsOfSpeech;
  final List<String> jlpt;
  final bool isCommon;
  final List<DictSense> senses;
  final List<DictForm> forms;
  String? translatedFrom;

  DictWord({
    required this.id,
    required this.word,
    required this.reading,
    required this.romaji,
    required this.meanings,
    required this.partsOfSpeech,
    required this.jlpt,
    required this.isCommon,
    required this.senses,
    required this.forms,
    this.translatedFrom,
  });

  String get jlptLabel {
    if (jlpt.isEmpty) return '';
    final n = jlpt.first.replaceAll('jlpt-', '').toUpperCase();
    return n;
  }

  String get primaryPos {
    if (partsOfSpeech.isEmpty) return '';
    return partsOfSpeech.first;
  }

  String get audioUrl {
    final kana = reading.isNotEmpty ? reading : word;
    final kanji = word;
    return 'https://assets.languagepod101.com/dictionary/japanese/audiomp3.php'
        '?kana=${Uri.encodeQueryComponent(kana)}'
        '&kanji=${Uri.encodeQueryComponent(kanji)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'reading': reading,
        'romaji': romaji,
        'meanings': meanings,
        'partsOfSpeech': partsOfSpeech,
        'jlpt': jlpt,
        'isCommon': isCommon,
        'senses': senses.map((s) => s.toJson()).toList(),
        'forms': forms.map((f) => f.toJson()).toList(),
      };

  factory DictWord.fromJson(Map<String, dynamic> json) {
    return DictWord(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      reading: json['reading'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
      meanings: (json['meanings'] as List? ?? []).cast<String>(),
      partsOfSpeech: (json['partsOfSpeech'] as List? ?? []).cast<String>(),
      jlpt: (json['jlpt'] as List? ?? []).cast<String>(),
      isCommon: json['isCommon'] as bool? ?? false,
      senses: (json['senses'] as List? ?? [])
          .whereType<Map>()
          .map((e) => DictSense.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      forms: (json['forms'] as List? ?? [])
          .whereType<Map>()
          .map((e) => DictForm.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DictSense {
  final List<String> definitions;
  final List<String> partsOfSpeech;
  final List<String> tags;
  final List<String> seeAlso;
  final List<String> info;

  const DictSense({
    required this.definitions,
    required this.partsOfSpeech,
    required this.tags,
    required this.seeAlso,
    required this.info,
  });

  Map<String, dynamic> toJson() => {
        'definitions': definitions,
        'partsOfSpeech': partsOfSpeech,
        'tags': tags,
        'seeAlso': seeAlso,
        'info': info,
      };

  factory DictSense.fromJson(Map<String, dynamic> json) {
    return DictSense(
      definitions: (json['definitions'] as List? ?? []).cast<String>(),
      partsOfSpeech: (json['partsOfSpeech'] as List? ?? []).cast<String>(),
      tags: (json['tags'] as List? ?? []).cast<String>(),
      seeAlso: (json['seeAlso'] as List? ?? []).cast<String>(),
      info: (json['info'] as List? ?? []).cast<String>(),
    );
  }
}

class DictForm {
  final String word;
  final String reading;

  const DictForm({required this.word, required this.reading});

  Map<String, dynamic> toJson() => {'word': word, 'reading': reading};

  factory DictForm.fromJson(Map<String, dynamic> json) {
    return DictForm(
      word: json['word'] as String? ?? '',
      reading: json['reading'] as String? ?? '',
    );
  }
}

class KanjiInfo {
  final String kanji;
  final String meaning;
  final List<String> onyomi;
  final List<String> kunyomi;
  final int strokeCount;
  final String jlpt;
  final int? grade;
  final List<String> kunyomiExamples;

  const KanjiInfo({
    required this.kanji,
    required this.meaning,
    required this.onyomi,
    required this.kunyomi,
    required this.strokeCount,
    required this.jlpt,
    required this.grade,
    required this.kunyomiExamples,
  });
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaizen/pages/dictionary/dictionary_models.dart';

class DictionaryStore {
  static const _favKey = 'zaizen_dict_favs_v1';
  static const _recentKey = 'zaizen_dict_recent_v1';

  List<DictWord> favorites = [];
  List<String> recents = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = (prefs.getStringList(_favKey) ?? [])
        .map((raw) {
          try {
            return DictWord.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<DictWord>()
        .toList();
    recents = prefs.getStringList(_recentKey) ?? [];
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favKey,
      favorites.map((w) => jsonEncode(w.toJson())).toList(),
    );
    await prefs.setStringList(_recentKey, recents.take(16).toList());
  }

  bool isSaved(DictWord word) => favorites.any((f) => f.id == word.id);

  Future<void> toggleFavorite(DictWord word) async {
    final i = favorites.indexWhere((f) => f.id == word.id);
    if (i >= 0) {
      favorites.removeAt(i);
    } else {
      favorites.insert(0, word);
    }
    await _persist();
  }

  Future<void> addRecent(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    recents.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    recents.insert(0, q);
    if (recents.length > 16) recents = recents.take(16).toList();
    await _persist();
  }

  Future<void> clearRecents() async {
    recents = [];
    await _persist();
  }
}

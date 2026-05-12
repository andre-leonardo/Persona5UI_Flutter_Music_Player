// lib/utilis/favorites_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phantom_tunes/utilis/app_state.dart';

const String _favoritesKey = 'favorite_song_ids';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favoritesKey) ?? [];
    favoriteSongIds.value = ids.map(int.parse).toSet();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesKey,
      favoriteSongIds.value.map((id) => id.toString()).toList(),
    );
  }

  Future<void> toggleFavorite(int songId) async {
    final current = Set<int>.from(favoriteSongIds.value);
    if (current.contains(songId)) {
      current.remove(songId);
    } else {
      current.add(songId);
    }
    favoriteSongIds.value = current;
    await _saveFavorites();
  }

  bool isFavorite(int songId) => favoriteSongIds.value.contains(songId);
}

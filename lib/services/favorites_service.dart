import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService extends ChangeNotifier {
  final Set<String> _favorites = {};
  final _supabase = Supabase.instance.client;

  bool isFavorite(String name) => _favorites.contains(name);
  Set<String> get favorites => Set.unmodifiable(_favorites);

  /// Load wishlist from Supabase (call after login)
  Future<void> loadFromSupabase() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final data = await _supabase
          .from('wishlist')
          .select('item_name')
          .eq('user_id', userId);
      _favorites.clear();
      for (final row in data) {
        _favorites.add(row['item_name'] as String);
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Toggle favourite — updates local state immediately, syncs to Supabase in background
  void toggleFavorite(String name) {
    if (_favorites.contains(name)) {
      _favorites.remove(name);
      _removeFromSupabase(name);
    } else {
      _favorites.add(name);
      _addToSupabase(name);
    }
    notifyListeners();
  }

  Future<void> _addToSupabase(String name) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase.from('wishlist').insert({
        'user_id': userId,
        'item_name': name,
      });
    } catch (_) {}
  }

  Future<void> _removeFromSupabase(String name) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase
          .from('wishlist')
          .delete()
          .eq('user_id', userId)
          .eq('item_name', name);
    } catch (_) {}
  }

  /// Clear local state on logout
  void clear() {
    _favorites.clear();
    notifyListeners();
  }
}

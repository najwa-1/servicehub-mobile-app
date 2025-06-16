import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class viewRatingRepository {
  Future<List<Map<String, dynamic>>> loadRatings(String serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ratings_$serviceId';
    final storedRatings = prefs.getString(key);
    if (storedRatings != null) {
      final decoded = jsonDecode(storedRatings);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    }
    return [];
  }

  Future<void> saveRatings(String serviceId, List<Map<String, dynamic>> ratings) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ratings_$serviceId';
    final encoded = jsonEncode(ratings);
    await prefs.setString(key, encoded);
  }
  
  Future<void> saveSingleRating(String serviceId, Map<String, dynamic> newRating) async {
    final ratings = await loadRatings(serviceId);
    ratings.add(newRating);
    await saveRatings(serviceId, ratings);
  }
}

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/game_2048_saved_session.dart';

class Game2048LocalStore {
  static const String _bestScoreKey = 'game_2048_best_score';
  static const String _sessionKey = 'game_2048_session';
  final FlutterSecureStorage _storage;

  Game2048LocalStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<int> loadBestScore() async {
    try {
      final value = await _storage.read(key: _bestScoreKey);
      if (value != null) {
        return int.tryParse(value) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> saveBestScore(int score) async {
    try {
      await _storage.write(key: _bestScoreKey, value: score.toString());
    } catch (_) {}
  }

  Future<Game2048SavedSession?> loadSession() async {
    try {
      final value = await _storage.read(key: _sessionKey);
      if (value != null) {
        final Map<String, dynamic> json = jsonDecode(value);
        if (json['board'] is List && (json['board'] as List).length == 16) {
          return Game2048SavedSession.fromJson(json);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveSession(Game2048SavedSession session) async {
    try {
      final value = jsonEncode(session.toJson());
      await _storage.write(key: _sessionKey, value: value);
    } catch (_) {}
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {}
  }
}

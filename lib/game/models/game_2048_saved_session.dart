import 'package:game_2048/game/logic/game_2048_enums.dart';

class Game2048SavedSession {
  final List<int> board;
  final int score;
  final int bestScore;
  final Game2048SessionStatus status;
  final bool isOverlayVisible;
  final bool hasDismissedWinOverlay;

  const Game2048SavedSession({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.status,
    required this.isOverlayVisible,
    required this.hasDismissedWinOverlay,
  });

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'score': score,
      'bestScore': bestScore,
      'status': status.name,
      'isOverlayVisible': isOverlayVisible,
      'hasDismissedWinOverlay': hasDismissedWinOverlay,
    };
  }

  factory Game2048SavedSession.fromJson(Map<String, dynamic> json) {
    return Game2048SavedSession(
      board: List<int>.from(json['board'] ?? []),
      score: json['score'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      status: Game2048SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => Game2048SessionStatus.playing,
      ),
      isOverlayVisible: json['isOverlayVisible'] ?? false,
      hasDismissedWinOverlay: json['hasDismissedWinOverlay'] ?? false,
    );
  }
}

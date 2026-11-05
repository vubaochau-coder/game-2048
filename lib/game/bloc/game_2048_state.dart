import 'package:equatable/equatable.dart';
import 'package:game_2048/game/logic/game_2048_enums.dart';

class Game2048State extends Equatable {
  final List<int> board;
  final int score;
  final int bestScore;
  final Game2048SessionStatus status;
  final bool isOverlayVisible;
  final bool hasDismissedWinOverlay;
  final List<int> spawnedTileIndices;
  final List<int> mergedTileIndices;

  /// Máy đang tự chơi. Không lưu vào session: mở lại app luôn ở chế độ tay.
  final bool isAutoPlaying;

  const Game2048State({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.status,
    required this.isOverlayVisible,
    required this.hasDismissedWinOverlay,
    this.spawnedTileIndices = const [],
    this.mergedTileIndices = const [],
    this.isAutoPlaying = false,
  });

  factory Game2048State.initial() {
    return const Game2048State(
      board: [],
      score: 0,
      bestScore: 0,
      status: Game2048SessionStatus.initial,
      isOverlayVisible: false,
      hasDismissedWinOverlay: false,
      spawnedTileIndices: [],
      mergedTileIndices: [],
    );
  }

  Game2048State copyWith({
    List<int>? board,
    int? score,
    int? bestScore,
    Game2048SessionStatus? status,
    bool? isOverlayVisible,
    bool? hasDismissedWinOverlay,
    List<int>? spawnedTileIndices,
    List<int>? mergedTileIndices,
    bool? isAutoPlaying,
  }) {
    return Game2048State(
      board: board ?? this.board,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      status: status ?? this.status,
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
      hasDismissedWinOverlay:
          hasDismissedWinOverlay ?? this.hasDismissedWinOverlay,
      spawnedTileIndices: spawnedTileIndices ?? this.spawnedTileIndices,
      mergedTileIndices: mergedTileIndices ?? this.mergedTileIndices,
      isAutoPlaying: isAutoPlaying ?? this.isAutoPlaying,
    );
  }

  @override
  List<Object?> get props {
    return [
      board,
      score,
      bestScore,
      status,
      isOverlayVisible,
      hasDismissedWinOverlay,
      spawnedTileIndices,
      mergedTileIndices,
      isAutoPlaying,
    ];
  }
}

class Game2048MoveResult {
  final List<int> board;
  final int scoreGain;
  final bool didMove;
  final bool didReach2048;
  final List<int> spawnedTileIndices;
  final List<int> mergedTileIndices;

  const Game2048MoveResult({
    required this.board,
    required this.scoreGain,
    required this.didMove,
    required this.didReach2048,
    this.spawnedTileIndices = const [],
    this.mergedTileIndices = const [],
  });
}

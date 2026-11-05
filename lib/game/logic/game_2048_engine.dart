import 'dart:math';
import 'game_2048_enums.dart';
import 'game_2048_move_result.dart';

class Game2048Engine {
  final Random _rng;

  Game2048Engine({Random? rng}) : _rng = rng ?? Random();

  /// Creates a board with hai starting tiles.
  List<int> createInitialBoard() {
    List<int> board = List.filled(16, 0);
    final (b1, _) = _spawnTile(board);
    final (b2, _) = _spawnTile(b1);
    return b2;
  }

  /// Spawns a new tile (2 hoặc 4) on an empty spot.
  (List<int>, int?) _spawnTile(List<int> board) {
    List<int> emptyIndices = [];
    for (int i = 0; i < 16; i++) {
      if (board[i] == 0) emptyIndices.add(i);
    }

    if (emptyIndices.isEmpty) return (board, null);

    final index = emptyIndices[_rng.nextInt(emptyIndices.length)];
    final value = _rng.nextDouble() < 0.9 ? 2 : 4;

    final newBoard = List<int>.from(board);
    newBoard[index] = value;
    return (newBoard, index);
  }

  /// Moves the board in a specific direction.
  Game2048MoveResult move(List<int> board, Game2048Direction direction) {
    List<List<int>> lines = _getLines(board, direction);
    int totalScoreGain = 0;
    bool moved = false;
    bool reach2048 = false;

    List<List<int>> movedLines = [];
    List<List<int>> mergedIndicesInLines = [];

    for (var line in lines) {
      final result = _moveLine(line);
      movedLines.add(result.line);
      mergedIndicesInLines.add(result.mergedIndices);
      totalScoreGain += result.scoreGain;
      if (result.moved) moved = true;
      if (result.reach2048) reach2048 = true;
    }

    if (!moved) {
      return Game2048MoveResult(
        board: board,
        scoreGain: 0,
        didMove: false,
        didReach2048: false,
      );
    }

    List<int> newBoard = _reconstructBoard(movedLines, direction);
    List<int> absoluteMergedIndices = _reconstructIndices(
      mergedIndicesInLines,
      direction,
    );

    final (spawnedBoard, spawnedIndex) = _spawnTile(newBoard);

    return Game2048MoveResult(
      board: spawnedBoard,
      scoreGain: totalScoreGain,
      didMove: true,
      didReach2048: reach2048,
      spawnedTileIndices: spawnedIndex != null ? [spawnedIndex] : [],
      mergedTileIndices: absoluteMergedIndices,
    );
  }

  /// Checks if any move is possible.
  bool canMove(List<int> board) {
    if (board.contains(0)) return true;

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[r * 4 + c] == board[r * 4 + c + 1]) return true;
      }
    }

    for (int c = 0; c < 4; c++) {
      for (int r = 0; r < 3; r++) {
        if (board[r * 4 + c] == board[(r + 1) * 4 + c]) return true;
      }
    }

    return false;
  }

  List<List<int>> _getLines(List<int> board, Game2048Direction direction) {
    List<List<int>> lines = [];
    switch (direction) {
      case Game2048Direction.left:
        for (int i = 0; i < 4; i++) {
          lines.add(board.sublist(i * 4, i * 4 + 4));
        }
        break;
      case Game2048Direction.right:
        for (int i = 0; i < 4; i++) {
          lines.add(board.sublist(i * 4, i * 4 + 4).reversed.toList());
        }
        break;
      case Game2048Direction.up:
        for (int c = 0; c < 4; c++) {
          lines.add([board[c], board[c + 4], board[c + 8], board[c + 12]]);
        }
        break;
      case Game2048Direction.down:
        for (int c = 0; c < 4; c++) {
          lines.add([board[c + 12], board[c + 8], board[c + 4], board[c]]);
        }
        break;
    }
    return lines;
  }

  _LineMoveResult _moveLine(List<int> line) {
    List<int> original = List<int>.from(line);
    List<int> filtered = line.where((v) => v != 0).toList();

    List<int> result = [];
    List<int> mergedIndices = [];
    int scoreGain = 0;
    bool reach2048 = false;

    int i = 0;
    while (i < filtered.length) {
      if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
        int newValue = filtered[i] * 2;
        mergedIndices.add(result.length);
        result.add(newValue);
        scoreGain += newValue;
        if (newValue == 2048) reach2048 = true;
        i += 2;
      } else {
        result.add(filtered[i]);
        i++;
      }
    }

    while (result.length < 4) {
      result.add(0);
    }

    bool moved = false;
    for (int j = 0; j < 4; j++) {
      if (result[j] != original[j]) {
        moved = true;
        break;
      }
    }

    return _LineMoveResult(
      line: result,
      mergedIndices: mergedIndices,
      scoreGain: scoreGain,
      moved: moved,
      reach2048: reach2048,
    );
  }

  List<int> _reconstructBoard(
    List<List<int>> lines,
    Game2048Direction direction,
  ) {
    List<int> board = List.filled(16, 0);
    switch (direction) {
      case Game2048Direction.left:
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 4; j++) {
            board[i * 4 + j] = lines[i][j];
          }
        }
        break;
      case Game2048Direction.right:
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 4; j++) {
            board[i * 4 + j] = lines[i][3 - j];
          }
        }
        break;
      case Game2048Direction.up:
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 4; j++) {
            board[j * 4 + i] = lines[i][j];
          }
        }
        break;
      case Game2048Direction.down:
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 4; j++) {
            board[(3 - j) * 4 + i] = lines[i][j];
          }
        }
        break;
    }
    return board;
  }

  List<int> _reconstructIndices(
    List<List<int>> mergedLines,
    Game2048Direction direction,
  ) {
    List<int> absoluteIndices = [];
    for (int i = 0; i < 4; i++) {
      for (int relativeIndex in mergedLines[i]) {
        switch (direction) {
          case Game2048Direction.left:
            absoluteIndices.add(i * 4 + relativeIndex);
            break;
          case Game2048Direction.right:
            absoluteIndices.add(i * 4 + (3 - relativeIndex));
            break;
          case Game2048Direction.up:
            absoluteIndices.add(relativeIndex * 4 + i);
            break;
          case Game2048Direction.down:
            absoluteIndices.add((3 - relativeIndex) * 4 + i);
            break;
        }
      }
    }
    return absoluteIndices;
  }
}

class _LineMoveResult {
  final List<int> line;
  final List<int> mergedIndices;
  final int scoreGain;
  final bool moved;
  final bool reach2048;

  _LineMoveResult({
    required this.line,
    required this.mergedIndices,
    required this.scoreGain,
    required this.moved,
    required this.reach2048,
  });
}

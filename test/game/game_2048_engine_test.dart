import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/game/logic/game_2048_engine.dart';
import 'package:game_2048/game/logic/game_2048_enums.dart';

void main() {
  late Game2048Engine engine;

  setUp(() {
    engine = Game2048Engine();
  });

  group('2048 Engine Tests', () {
    test('createInitialBoard should have exactly 2 non-zero tiles', () {
      final board = engine.createInitialBoard();
      final nonZeroCount = board.where((v) => v != 0).length;
      expect(nonZeroCount, 2);
    });

    test('simple merge left [2, 2, 0, 0] -> [4, 0, 0, 0]', () {
      final board = [2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final result = engine.move(board, Game2048Direction.left);

      expect(result.didMove, true);
      // After move, a new tile is spawned, so we check the first row mainly
      // But we need to account for the spawned tile.
      // To strictly test merge, I'll check if the merged value exists.
      expect(result.board[0], 4);
      expect(result.scoreGain, 4);
    });

    test('merge with gaps [2, 0, 2, 0] -> [4, 0, 0, 0]', () {
      final board = [2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final result = engine.move(board, Game2048Direction.left);
      expect(result.board[0], 4);
      expect(result.didMove, true);
    });

    test('no double merge in one move [2, 2, 2, 0] -> [4, 2, 0, 0]', () {
      final board = [2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final result = engine.move(board, Game2048Direction.left);
      expect(result.board[1], 2);
      expect(result.board[0], 4);
    });

    test('multiple merges [2, 2, 2, 2] -> [4, 4, 0, 0]', () {
      final board = [2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final result = engine.move(board, Game2048Direction.left);
      expect(result.board[0], 4);
      expect(result.board[1], 4);
      expect(result.scoreGain, 8);
    });

    test('no move if direction is blocked [2, 4, 8, 16] left -> no move', () {
      final board = [
        2,
        4,
        8,
        16,
        32,
        64,
        128,
        256,
        2,
        4,
        8,
        16,
        32,
        64,
        128,
        256,
      ];
      final result = engine.move(board, Game2048Direction.left);
      expect(result.didMove, false);
      expect(result.board, board);
    });

    test('canMove returns false when board is full and no merges possible', () {
      final board = [2, 4, 2, 4, 4, 2, 4, 2, 2, 4, 2, 4, 4, 2, 4, 2];
      expect(engine.canMove(board), false);
    });

    test('canMove returns true when board is full but merges possible', () {
      final board = [
        2,
        2,
        4,
        8,
        16,
        32,
        64,
        128,
        256,
        512,
        1024,
        2048,
        2,
        4,
        8,
        16,
      ];
      expect(engine.canMove(board), true);
    });

    test('didReach2048 is true when 1024 merges with 1024', () {
      final board = [1024, 1024, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final result = engine.move(board, Game2048Direction.left);
      expect(result.didReach2048, true);
    });
  });
}

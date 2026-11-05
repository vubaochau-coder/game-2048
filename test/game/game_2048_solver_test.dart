import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/game/logic/game_2048_engine.dart';
import 'package:game_2048/game/logic/game_2048_solver.dart';

void main() {
  group('Game2048Solver', () {
    test('returns null when no move is possible', () {
      final board = [
        2, 4, 2, 4, //
        4, 2, 4, 2, //
        2, 4, 2, 4, //
        4, 2, 4, 2, //
      ];
      expect(Game2048Solver().bestMove(board), isNull);
    });

    test('only returns directions that actually move the board', () {
      // Chỉ trượt sang phải hoặc xuống là đổi được bàn cờ.
      final board = [
        2, 0, 0, 0, //
        4, 0, 0, 0, //
        8, 0, 0, 0, //
        16, 32, 64, 128, //
      ];
      final engine = Game2048Engine(rng: Random(1));
      final direction = Game2048Solver().bestMove(board);

      expect(direction, isNotNull);
      expect(engine.move(board, direction!).didMove, isTrue);
    });

    test('plays a full game and reaches 2048', () {
      final engine = Game2048Engine(rng: Random(0));
      final solver = Game2048Solver();
      var board = engine.createInitialBoard();

      while (engine.canMove(board) && !board.contains(2048)) {
        final direction = solver.bestMove(board);
        expect(direction, isNotNull);
        final result = engine.move(board, direction!);
        expect(result.didMove, isTrue);
        board = result.board;
      }

      expect(board.reduce(max), greaterThanOrEqualTo(2048));
    });
  });
}

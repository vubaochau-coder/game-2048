import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/game/bloc/game_2048_bloc.dart';
import 'package:game_2048/game/bloc/game_2048_event.dart';
import 'package:game_2048/game/bloc/game_2048_state.dart';
import 'package:game_2048/game/logic/game_2048_engine.dart';
import 'package:game_2048/game/logic/game_2048_enums.dart';
import 'package:game_2048/game/logic/game_2048_move_result.dart';
import 'package:game_2048/game/logic/game_2048_local_store.dart';
import 'package:game_2048/game/models/game_2048_saved_session.dart';

class FakeGame2048Engine extends Game2048Engine {
  Game2048MoveResult? nextMoveResult;
  bool nextCanMove = true;

  @override
  Game2048MoveResult move(List<int> board, Game2048Direction direction) {
    return nextMoveResult ?? super.move(board, direction);
  }

  @override
  bool canMove(List<int> board) => nextCanMove;

  @override
  List<int> createInitialBoard() =>
      List.filled(16, 0)
        ..[0] = 2
        ..[1] = 2;
}

class FakeGame2048LocalStore extends Game2048LocalStore {
  int bestScoreValue = 0;
  Game2048SavedSession? savedSession;

  @override
  Future<int> loadBestScore() async => bestScoreValue;
  @override
  Future<void> saveBestScore(int score) async {
    bestScoreValue = score;
  }

  @override
  Future<Game2048SavedSession?> loadSession() async => savedSession;
  @override
  Future<void> saveSession(Game2048SavedSession session) async {
    savedSession = session;
  }

  @override
  Future<void> clearSession() async {
    savedSession = null;
  }
}

Future<void> _startNewGame(Game2048Bloc bloc) async {
  bloc.add(const Game2048Started());
  await bloc.stream.firstWhere(
    (s) => s.status == Game2048SessionStatus.playing,
  );
}

void main() {
  late FakeGame2048Engine fakeEngine;
  late FakeGame2048LocalStore fakeStore;
  late Game2048Bloc bloc;

  setUp(() {
    fakeEngine = FakeGame2048Engine();
    fakeStore = FakeGame2048LocalStore();
    bloc = Game2048Bloc(engine: fakeEngine, store: fakeStore);
  });

  tearDown(() {
    bloc.close();
  });

  group('Game2048Bloc Phase 4 - Resume Session Tests', () {
    test('Started should restore from saved session if valid', () async {
      final board =
          List.filled(16, 0)
            ..[0] = 1024
            ..[1] = 1024;
      fakeStore.savedSession = Game2048SavedSession(
        board: board,
        score: 2048,
        bestScore: 2048,
        status: Game2048SessionStatus.playing,
        isOverlayVisible: false,
        hasDismissedWinOverlay: false,
      );

      bloc.add(const Game2048Started());

      await expectLater(
        bloc.stream,
        emits(
          predicate<Game2048State>(
            (s) =>
                s.board == board &&
                s.score == 2048 &&
                s.status == Game2048SessionStatus.playing,
          ),
        ),
      );
    });

    test('Started should restore won state and overlay visibility', () async {
      fakeStore.savedSession = Game2048SavedSession(
        board: List.filled(16, 0)..[0] = 2048,
        score: 4000,
        bestScore: 5000,
        status: Game2048SessionStatus.won,
        isOverlayVisible: true,
        hasDismissedWinOverlay: false,
      );

      bloc.add(const Game2048Started());

      await expectLater(
        bloc.stream,
        emits(
          predicate<Game2048State>(
            (s) =>
                s.status == Game2048SessionStatus.won &&
                s.isOverlayVisible == true,
          ),
        ),
      );
    });

    test('Started should fallback to new game if session is null', () async {
      fakeStore.savedSession = null;
      bloc.add(const Game2048Started());

      await expectLater(
        bloc.stream,
        emits(
          predicate<Game2048State>(
            (s) => s.status == Game2048SessionStatus.playing && s.score == 0,
          ),
        ),
      );
      // Verify first session was saved
      expect(fakeStore.savedSession, isNotNull);
    });

    test(
      'RestartRequested should overwrite with a brand new session',
      () async {
        fakeStore.savedSession = Game2048SavedSession(
          board: List.filled(16, 2),
          score: 100,
          bestScore: 100,
          status: Game2048SessionStatus.playing,
          isOverlayVisible: false,
          hasDismissedWinOverlay: false,
        );

        bloc.add(const Game2048RestartRequested());

        await expectLater(
          bloc.stream,
          emits(predicate<Game2048State>((s) => s.score == 0)),
        );

        expect(fakeStore.savedSession!.score, 0);
        expect(fakeStore.savedSession!.board.where((v) => v != 0).length, 2);
      },
    );
  });

  group('Game2048Bloc Phase 4 - Polish Regression Tests', () {
    test('Should update and persist best score when exceeded', () async {
      fakeStore.bestScoreValue = 100;
      bloc.add(const Game2048Started());
      await bloc.stream.first;

      fakeEngine.nextMoveResult = Game2048MoveResult(
        board: List.filled(16, 0),
        scoreGain: 150,
        didMove: true,
        didReach2048: false,
      );

      bloc.add(const Game2048SwipeRequested(Game2048Direction.left));

      await expectLater(
        bloc.stream,
        emits(
          predicate<Game2048State>((s) => s.bestScore == 150 && s.score == 150),
        ),
      );
      expect(fakeStore.bestScoreValue, 150);
      expect(fakeStore.savedSession!.score, 150);
    });

    test('Should provide animation metadata on move', () async {
      bloc.add(const Game2048Started());
      await bloc.stream.first;

      fakeEngine.nextMoveResult = Game2048MoveResult(
        board: List.filled(16, 0),
        scoreGain: 4,
        didMove: true,
        didReach2048: false,
        spawnedTileIndices: [5],
        mergedTileIndices: [0],
      );

      bloc.add(const Game2048SwipeRequested(Game2048Direction.left));

      await expectLater(
        bloc.stream,
        emits(
          predicate<Game2048State>(
            (s) =>
                s.spawnedTileIndices.contains(5) &&
                s.mergedTileIndices.contains(0),
          ),
        ),
      );
    });
  });

  group('Game2048Bloc Phase 3 - Logic Regression Tests', () {
    test(
      'Winning flow: detecting 2048, delay, reveal, and keep going',
      () async {
        fakeEngine.nextMoveResult = Game2048MoveResult(
          board:
              List.filled(16, 0)
                ..[0] = 2048
                ..[1] = 2,
          scoreGain: 2048,
          didMove: true,
          didReach2048: true,
        );

        bloc.add(const Game2048Started());
        await bloc.stream.first;

        bloc.add(const Game2048SwipeRequested(Game2048Direction.left));

        await expectLater(
          bloc.stream,
          emits(
            predicate<Game2048State>(
              (state) =>
                  state.status == Game2048SessionStatus.won &&
                  state.isOverlayVisible == false,
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1300));
        expect(bloc.state.isOverlayVisible, true);
        expect(fakeStore.savedSession!.isOverlayVisible, true);

        bloc.add(const Game2048ContinueAfterWinRequested());
        await expectLater(
          bloc.stream,
          emits(
            predicate<Game2048State>(
              (state) =>
                  state.status == Game2048SessionStatus.playing &&
                  state.isOverlayVisible == false &&
                  state.hasDismissedWinOverlay == true,
            ),
          ),
        );
        expect(fakeStore.savedSession!.status, Game2048SessionStatus.playing);
      },
    );
  });

  group('Game2048Bloc auto play', () {
    setUp(() {
      bloc.close();
      bloc = Game2048Bloc(
        engine: fakeEngine,
        store: fakeStore,
        autoPlayInterval: const Duration(milliseconds: 10),
      );
    });

    test('toggling on makes moves automatically, toggling off stops', () async {
      await _startNewGame(bloc);
      final initialBoard = bloc.state.board;

      bloc.add(const Game2048AutoPlayToggled());
      await bloc.stream.firstWhere((s) => s.isAutoPlaying);
      await bloc.stream.firstWhere((s) => s.board != initialBoard);

      bloc.add(const Game2048AutoPlayToggled());
      await bloc.stream.firstWhere((s) => !s.isAutoPlaying);

      final boardAfterStop = bloc.state.board;
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(bloc.state.board, boardAfterStop);
    });

    test('manual swipe takes control back from auto play', () async {
      await _startNewGame(bloc);
      bloc.add(const Game2048AutoPlayToggled());
      await bloc.stream.firstWhere((s) => s.isAutoPlaying);

      bloc.add(const Game2048SwipeRequested(Game2048Direction.left));
      await bloc.stream.firstWhere((s) => !s.isAutoPlaying);
      expect(bloc.state.isAutoPlaying, isFalse);
    });

    test('restart stops auto play', () async {
      await _startNewGame(bloc);
      bloc.add(const Game2048AutoPlayToggled());
      await bloc.stream.firstWhere((s) => s.isAutoPlaying);

      bloc.add(const Game2048RestartRequested());
      await bloc.stream.firstWhere((s) => !s.isAutoPlaying);
      expect(bloc.state.status, Game2048SessionStatus.playing);
    });

    test('auto play stops when the game is over', () async {
      await _startNewGame(bloc);
      fakeEngine.nextCanMove = false;

      bloc.add(const Game2048AutoPlayToggled());
      final finalState = await bloc.stream.firstWhere(
        (s) => s.status == Game2048SessionStatus.gameOver && !s.isAutoPlaying,
      );
      expect(finalState.isAutoPlaying, isFalse);
    });

    test('cannot start auto play when the game is over', () async {
      await _startNewGame(bloc);
      fakeEngine.nextCanMove = false;
      bloc.add(const Game2048SwipeRequested(Game2048Direction.left));
      await bloc.stream.firstWhere(
        (s) => s.status == Game2048SessionStatus.gameOver,
      );

      bloc.add(const Game2048AutoPlayToggled());
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(bloc.state.isAutoPlaying, isFalse);
    });
  });
}

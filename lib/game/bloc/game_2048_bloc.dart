import 'package:game_2048/game/logic/game_2048_engine.dart';
import 'package:game_2048/game/logic/game_2048_enums.dart';
import 'dart:async';

import 'package:game_2048/game/logic/game_2048_local_store.dart';
import 'package:game_2048/game/logic/game_2048_solver.dart';
import 'package:game_2048/game/models/game_2048_saved_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_2048_event.dart';
import 'game_2048_state.dart';

class Game2048Bloc extends Bloc<Game2048Event, Game2048State> {
  final Game2048Engine _engine;
  final Game2048LocalStore _store;
  final Game2048Solver _solver;

  /// Khoảng cách giữa hai nước đi khi tự chơi (đủ để xem animation 200ms).
  final Duration autoPlayInterval;
  Timer? _autoPlayTimer;

  Game2048Bloc({
    Game2048Engine? engine,
    Game2048LocalStore? store,
    Game2048Solver? solver,
    this.autoPlayInterval = const Duration(milliseconds: 250),
  }) : _engine = engine ?? Game2048Engine(),
       _store = store ?? Game2048LocalStore(),
       _solver = solver ?? Game2048Solver(),
       super(Game2048State.initial()) {
    on<Game2048Started>(_onStarted);
    on<Game2048SwipeRequested>(_onSwipeRequested);
    on<Game2048RestartRequested>(_onRestartRequested);
    on<Game2048ContinueAfterWinRequested>(_onContinueAfterWinRequested);
    on<Game2048TryAgainRequested>(_onTryAgainRequested);
    on<Game2048OverlayRevealRequested>(_onOverlayRevealRequested);
    on<Game2048AnimationConsumed>(_onAnimationConsumed);
    on<Game2048AutoPlayToggled>(_onAutoPlayToggled);
    on<Game2048AutoPlayTicked>(_onAutoPlayTicked);
  }

  @override
  Future<void> close() {
    _stopAutoPlayTimer();
    return super.close();
  }

  _onStarted(Game2048Started event, Emitter emit) async {
    final bestScore = await _store.loadBestScore();
    final savedSession = await _store.loadSession();

    if (savedSession != null) {
      emit(
        state.copyWith(
          board: savedSession.board,
          score: savedSession.score,
          bestScore: bestScore, // Always use latest best score
          status: savedSession.status,
          isOverlayVisible: savedSession.isOverlayVisible,
          hasDismissedWinOverlay: savedSession.hasDismissedWinOverlay,
          spawnedTileIndices: [],
          mergedTileIndices: [],
        ),
      );
    } else {
      final board = _engine.createInitialBoard();
      final newState = state.copyWith(
        board: board,
        score: 0,
        bestScore: bestScore,
        status: Game2048SessionStatus.playing,
        isOverlayVisible: false,
        hasDismissedWinOverlay: false,
        spawnedTileIndices: [],
        mergedTileIndices: [],
      );
      emit(newState);
      _persistSession(newState);
    }
  }

  _onSwipeRequested(Game2048SwipeRequested event, Emitter emit) {
    // Người chơi tự vuốt -> giành lại quyền điều khiển.
    if (state.isAutoPlaying) _stopAutoPlay(emit);
    _applyMove(event.direction, emit);
  }

  _onAutoPlayToggled(Game2048AutoPlayToggled event, Emitter emit) {
    if (state.isAutoPlaying) {
      _stopAutoPlay(emit);
      return;
    }
    if (state.status != Game2048SessionStatus.playing) return;
    if (state.isOverlayVisible) return;

    emit(state.copyWith(isAutoPlaying: true));
    _autoPlayTimer = Timer.periodic(autoPlayInterval, (_) {
      if (!isClosed) add(const Game2048AutoPlayTicked());
    });
  }

  _onAutoPlayTicked(Game2048AutoPlayTicked event, Emitter emit) {
    if (!state.isAutoPlaying) return;
    if (state.status != Game2048SessionStatus.playing ||
        state.isOverlayVisible) {
      _stopAutoPlay(emit);
      return;
    }

    final direction = _solver.bestMove(state.board);
    if (direction == null) {
      _stopAutoPlay(emit);
      return;
    }
    _applyMove(direction, emit);

    // Thắng (chạm 2048) hoặc thua -> dừng để người chơi xem kết quả.
    if (state.status != Game2048SessionStatus.playing) _stopAutoPlay(emit);
  }

  _stopAutoPlay(Emitter emit) {
    _stopAutoPlayTimer();
    if (state.isAutoPlaying) emit(state.copyWith(isAutoPlaying: false));
  }

  _stopAutoPlayTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  _applyMove(Game2048Direction direction, Emitter emit) {
    if (state.status != Game2048SessionStatus.playing) return;
    if (state.isOverlayVisible) return;

    final result = _engine.move(state.board, direction);
    if (!result.didMove) return;

    final newScore = state.score + result.scoreGain;
    int newBestScore = state.bestScore;
    if (newScore > newBestScore) {
      newBestScore = newScore;
      _store.saveBestScore(newBestScore);
    }

    Game2048SessionStatus newStatus = state.status;
    if (result.didReach2048 && !state.hasDismissedWinOverlay) {
      newStatus = Game2048SessionStatus.won;
    }

    if (!_engine.canMove(result.board)) {
      newStatus = Game2048SessionStatus.gameOver;
    }

    final newState = state.copyWith(
      board: result.board,
      score: newScore,
      bestScore: newBestScore,
      status: newStatus,
      isOverlayVisible: false,
      spawnedTileIndices: result.spawnedTileIndices,
      mergedTileIndices: result.mergedTileIndices,
    );
    emit(newState);
    _persistSession(newState);

    if (newStatus == Game2048SessionStatus.won ||
        newStatus == Game2048SessionStatus.gameOver) {
      add(const Game2048OverlayRevealRequested());
    }
  }

  _onRestartRequested(Game2048RestartRequested event, Emitter emit) {
    _resetGame(emit);
  }

  _onTryAgainRequested(Game2048TryAgainRequested event, Emitter emit) {
    _resetGame(emit);
  }

  _onContinueAfterWinRequested(
    Game2048ContinueAfterWinRequested event,
    Emitter emit,
  ) {
    if (state.status != Game2048SessionStatus.won) return;
    final newState = state.copyWith(
      status: Game2048SessionStatus.playing,
      isOverlayVisible: false,
      hasDismissedWinOverlay: true,
      spawnedTileIndices: [],
      mergedTileIndices: [],
    );
    emit(newState);
    _persistSession(newState);
  }

  _onOverlayRevealRequested(
    Game2048OverlayRevealRequested event,
    Emitter emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (state.status == Game2048SessionStatus.won &&
        !state.hasDismissedWinOverlay) {
      final newState = state.copyWith(isOverlayVisible: true);
      emit(newState);
      _persistSession(newState);
    } else if (state.status == Game2048SessionStatus.gameOver) {
      final newState = state.copyWith(isOverlayVisible: true);
      emit(newState);
      _persistSession(newState);
    }
  }

  _onAnimationConsumed(Game2048AnimationConsumed event, Emitter emit) {
    emit(state.copyWith(spawnedTileIndices: [], mergedTileIndices: []));
    // No need to persist here as animation indices are not in saved session
  }

  _resetGame(Emitter emit) {
    _stopAutoPlayTimer();
    final board = _engine.createInitialBoard();
    final newState = state.copyWith(
      board: board,
      score: 0,
      status: Game2048SessionStatus.playing,
      isOverlayVisible: false,
      hasDismissedWinOverlay: false,
      spawnedTileIndices: [],
      mergedTileIndices: [],
      isAutoPlaying: false,
    );
    emit(newState);
    _persistSession(newState);
  }

  _persistSession(Game2048State state) {
    final session = Game2048SavedSession(
      board: state.board,
      score: state.score,
      bestScore: state.bestScore,
      status: state.status,
      isOverlayVisible: state.isOverlayVisible,
      hasDismissedWinOverlay: state.hasDismissedWinOverlay,
    );
    _store.saveSession(session);
  }
}

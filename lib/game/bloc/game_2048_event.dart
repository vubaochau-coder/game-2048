import 'package:game_2048/game/logic/game_2048_enums.dart';

sealed class Game2048Event {
  const Game2048Event();
}

class Game2048Started extends Game2048Event {
  const Game2048Started();
}

class Game2048SwipeRequested extends Game2048Event {
  final Game2048Direction direction;

  const Game2048SwipeRequested(this.direction);
}

class Game2048RestartRequested extends Game2048Event {
  const Game2048RestartRequested();
}

class Game2048ContinueAfterWinRequested extends Game2048Event {
  const Game2048ContinueAfterWinRequested();
}

class Game2048TryAgainRequested extends Game2048Event {
  const Game2048TryAgainRequested();
}

class Game2048OverlayRevealRequested extends Game2048Event {
  const Game2048OverlayRevealRequested();
}

class Game2048AnimationConsumed extends Game2048Event {
  const Game2048AnimationConsumed();
}

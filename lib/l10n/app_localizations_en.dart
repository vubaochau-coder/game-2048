// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '2048';

  @override
  String get game2048Subtitle => 'Sliding tile puzzle';

  @override
  String get game2048Score => 'Score';

  @override
  String get game2048NewGame => 'New Game';

  @override
  String get game2048YouWin => 'You win!';

  @override
  String get game2048GameOver => 'Game over!';

  @override
  String get game2048TryAgain => 'Try again';

  @override
  String get game2048KeepGoing => 'Keep going';
}

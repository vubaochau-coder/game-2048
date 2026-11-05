// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => '2048';

  @override
  String get game2048Subtitle => 'Ghép ô trượt';

  @override
  String get game2048Score => 'Điểm';

  @override
  String get game2048NewGame => 'Ván mới';

  @override
  String get game2048YouWin => 'Bạn đã thắng!';

  @override
  String get game2048GameOver => 'Hết lượt!';

  @override
  String get game2048TryAgain => 'Thử lại';

  @override
  String get game2048KeepGoing => 'Tiếp tục';
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

extension ContextExt on BuildContext {
  ColorScheme get color => Theme.of(this).colorScheme;

  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge!;
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get labelSmall => Theme.of(this).textTheme.labelSmall!;

  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

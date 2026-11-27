import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// App strings for the current locale. Falls back to English where no
  /// localizations are installed (for example in isolated widget tests or the
  /// configuration error screen), so a missing delegate never crashes a screen.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('en'));
}

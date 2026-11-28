import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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

const _englishMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "27 Nov 2026" (or "27 Nov" without [withYear]) in the app language.
/// Uses English month names where locale date data is not loaded.
String formatDayMonth(
  BuildContext context,
  DateTime value, {
  bool withYear = true,
}) {
  final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  try {
    return DateFormat(withYear ? 'd MMM y' : 'd MMM', locale).format(value);
  } catch (_) {
    final text = '${value.day} ${_englishMonths[value.month - 1]}';
    return withYear ? '$text ${value.year}' : text;
  }
}

const _englishWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// "Friday, 27 Nov" in the app language.
String formatWeekdayDayMonth(BuildContext context, DateTime value) {
  final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  try {
    return DateFormat('EEEE, d MMM', locale).format(value);
  } catch (_) {
    return '${_englishWeekdays[value.weekday - 1]}, ${value.day} '
        '${_englishMonths[value.month - 1]}';
  }
}

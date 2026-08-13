from pathlib import Path


def replace_once(path_str: str, old: str, new: str) -> None:
    path = Path(path_str)
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path_str}: expected one match, found {count}')
    path.write_text(text.replace(old, new, 1))


replace_once(
    'lib/features/companion/domain/daily_companion.dart',
    '  final limit = minutes.clamp(1, 30);',
    '  final limit = minutes.clamp(1, 30).toInt();',
)

store = 'lib/features/companion/data/local_daily_companion_store.dart'
replace_once(
    store,
    "dailyQuestionGoal: (row['daily_question_goal'] as int).clamp(1, 100),",
    "dailyQuestionGoal: (row['daily_question_goal'] as int).clamp(1, 100).toInt(),",
)
replace_once(
    store,
    "reminderHour: (row['reminder_hour'] as int).clamp(0, 23),",
    "reminderHour: (row['reminder_hour'] as int).clamp(0, 23).toInt(),",
)
replace_once(
    store,
    "reminderMinute: (row['reminder_minute'] as int).clamp(0, 59),",
    "reminderMinute: (row['reminder_minute'] as int).clamp(0, 59).toInt(),",
)

service = 'lib/features/companion/services/study_reminder_service.dart'
replace_once(service, '      hour.clamp(0, 23),', '      hour.clamp(0, 23).toInt(),')
replace_once(service, '      minute.clamp(0, 59),', '      minute.clamp(0, 59).toInt(),')

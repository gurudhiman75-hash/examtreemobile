from pathlib import Path


def replace_once(path_str: str, old: str, new: str) -> None:
    path = Path(path_str)
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path_str}: expected one occurrence, found {count}: {old[:120]!r}')
    path.write_text(text.replace(old, new, 1))

# Keep background elapsed time strongly typed as int.
screen = 'lib/features/test_attempt/presentation/canonical_test_attempt_screen.dart'
replace_once(
    screen,
    '''    final adjusted = (remainingAtBackground - elapsed).clamp(0, remainingAtBackground);
''',
    '''    final adjusted = (remainingAtBackground - elapsed)
        .clamp(0, remainingAtBackground)
        .toInt();
''',
)

# Consume the canonical max-attempts value returned by the API.
dto = 'lib/core/models/exam_api_dto.dart'
replace_once(
    dto,
    '''    this.languages = const [],
  });
''',
    '''    this.languages = const [],
    this.maxAttempts = 99,
  });
''',
)
replace_once(
    dto,
    '''  final List<String> languages;

  factory TestDto.fromJson''',
    '''  final List<String> languages;
  final int maxAttempts;

  factory TestDto.fromJson''',
)
replace_once(
    dto,
    '''        languages: _stringList(json['languages']),
      );
''',
    '''        languages: _stringList(json['languages']),
        maxAttempts: _int(json['maxAttempts'], 99),
      );
''',
)
replace_once(
    dto,
    '''      maxAttempts: 99,
''',
    '''      maxAttempts: maxAttempts > 0 ? maxAttempts : 99,
''',
)

# Prevent an obviously exhausted completed-attempt allowance from presenting
# another start action. The backend remains authoritative for the final check.
details = 'lib/features/exams/presentation/exam_details_screen.dart'
replace_once(
    details,
    '''    final attemptLimit = exam.maxAttempts >= 99
        ? 'Unlimited'
        : '${exam.maxAttempts}';

    return RefreshIndicator(
''',
    '''    final attemptLimit = exam.maxAttempts >= 99
        ? 'Unlimited'
        : '${exam.maxAttempts}';
    final completedAttemptCount = completedAttemptsAsync.value;
    final attemptLimitReached = exam.maxAttempts < 99 &&
        completedAttemptCount != null &&
        completedAttemptCount >= exam.maxAttempts;

    return RefreshIndicator(
''',
)
replace_once(
    details,
    '''          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(text: 'Start or Resume Test', onPressed: onStart),
          const SizedBox(height: AppSpacing.xl),
''',
    '''          const SizedBox(height: AppSpacing.xl),
          if (attemptLimitReached) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                'You have used all ${exam.maxAttempts} allowed attempts for this test.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          PrimaryButton(
            text: attemptLimitReached ? 'Attempt limit reached' : 'Start or Resume Test',
            onPressed: attemptLimitReached ? null : onStart,
          ),
          const SizedBox(height: AppSpacing.xl),
''',
)

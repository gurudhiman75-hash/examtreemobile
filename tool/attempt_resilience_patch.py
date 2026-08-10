from pathlib import Path
import re

screen_path = Path('lib/features/test_attempt/presentation/canonical_test_attempt_screen.dart')
text = screen_path.read_text()


def replace_once(old: str, new: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'expected one occurrence, found {count}: {old[:100]!r}')
    text = text.replace(old, new, 1)


def regex_once(pattern: str, replacement: str) -> None:
    global text
    text, count = re.subn(pattern, replacement, text, count=1, flags=re.S)
    if count != 1:
        raise SystemExit(f'expected one regex occurrence, found {count}: {pattern[:100]!r}')


replace_once(
    "import '../../../core/theme/app_spacing.dart';\n",
    "import '../../../core/theme/app_spacing.dart';\n"
    "import '../../auth/presentation/providers/auth_providers.dart';\n"
    "import '../data/local_attempt_draft_store.dart';\n",
)

replace_once(
    "  Timer? _periodicAutosave;\n\n  String? _attemptId;",
    "  Timer? _periodicAutosave;\n"
    "  Timer? _localCheckpoint;\n\n"
    "  Future<bool>? _activeSave;\n"
    "  DateTime? _backgroundedAt;\n"
    "  int? _remainingAtBackground;\n"
    "  bool _isForeground = true;\n"
    "  bool _submissionPending = false;\n"
    "  final Map<String, int> _questionTimeSecondsById = <String, int>{};\n\n"
    "  String? _attemptId;",
)

replace_once(
    "    _periodicAutosave?.cancel();\n    super.dispose();",
    "    _periodicAutosave?.cancel();\n"
    "    _localCheckpoint?.cancel();\n"
    "    super.dispose();",
)

regex_once(
    r"  @override\n  void didChangeAppLifecycleState\(AppLifecycleState state\) \{.*?\n  \}\n\n  Future<void> _initialiseAttempt",
    '''  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _isForeground = false;
      _backgroundedAt ??= DateTime.now();
      _remainingAtBackground ??= _secondsRemaining;
      unawaited(_persistLocalDraft());
      unawaited(_saveSession());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _isForeground = true;
      _applyBackgroundElapsed();
      unawaited(_persistLocalDraft());
      if (_secondsRemaining <= 0) {
        unawaited(_handleTimeExpired());
      } else {
        unawaited(_saveSession());
      }
    }
  }

  void _applyBackgroundElapsed() {
    final backgroundedAt = _backgroundedAt;
    final remainingAtBackground = _remainingAtBackground;
    _backgroundedAt = null;
    _remainingAtBackground = null;
    if (backgroundedAt == null || remainingAtBackground == null) return;

    final elapsed = DateTime.now().difference(backgroundedAt).inSeconds;
    final adjusted = (remainingAtBackground - elapsed).clamp(0, remainingAtBackground);
    if (adjusted < _secondsRemaining && mounted) {
      setState(() => _secondsRemaining = adjusted);
    }
  }

  String? get _currentUserId =>
      ref.read(firebaseAuthProvider).currentUser?.uid.trim();

  Future<void> _persistLocalDraft() async {
    final attemptId = _attemptId;
    final userId = _currentUserId;
    if (attemptId == null || userId == null || userId.isEmpty || _initialising) {
      return;
    }
    try {
      await ref.read(attemptDraftStoreProvider).write(
            LocalAttemptDraft(
              userId: userId,
              testId: widget.exam.id,
              attemptId: attemptId,
              revision: _revision,
              state: _buildState(),
              localSavedAt: DateTime.now(),
            ),
          );
    } catch (_) {
      // Server autosave remains canonical. Local storage is a resilience mirror.
    }
  }

  Future<void> _deleteLocalDraft() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    try {
      await ref.read(attemptDraftStoreProvider).delete(
            userId: userId,
            testId: widget.exam.id,
          );
    } catch (_) {
      // A stale local draft is ignored if the server returns a different attempt.
    }
  }

  Future<void> _initialiseAttempt''',
)

regex_once(
    r"  Future<void> _initialiseAttempt\(\) async \{.*?\n  \}\n\n  void _startTimer",
    '''  Future<void> _initialiseAttempt() async {
    _timer?.cancel();
    _periodicAutosave?.cancel();
    _localCheckpoint?.cancel();
    setState(() {
      _initialising = true;
      _startupError = null;
      _timeExpired = false;
      _submissionPending = false;
    });

    try {
      final userId = _currentUserId;
      final localDraft = userId == null || userId.isEmpty
          ? null
          : await ref.read(attemptDraftStoreProvider).read(
                userId: userId,
                testId: widget.exam.id,
              );
      final session = await ref
          .read(attemptSessionRepositoryProvider)
          .startOrResume(testId: widget.exam.id);
      if (!mounted) return;
      if (session.id.isEmpty) {
        throw const AttemptSessionRepositoryException(
          'The server did not create an attempt session.',
          code: 'ATTEMPT_SESSION_MISSING',
        );
      }

      final recovered = recoverableLocalDraft(
        local: localDraft,
        activeAttemptId: session.id,
        remoteState: session.state,
      );
      final restoredState = recovered?.state ?? session.state;

      setState(() {
        _attemptId = session.id;
        _revision = session.revision;
        _lastSavedAt = session.savedAt;
        _syncFailed = recovered != null;
        if (restoredState != null) {
          _restoreState(restoredState);
        }
        _initialising = false;
        _timeExpired = _secondsRemaining <= 0;
      });

      if (localDraft != null && localDraft.attemptId != session.id) {
        await _deleteLocalDraft();
      }

      _periodicAutosave = Timer.periodic(
        const Duration(seconds: 30),
        (_) => unawaited(_saveSession()),
      );
      _localCheckpoint = Timer.periodic(
        const Duration(seconds: 5),
        (_) => unawaited(_persistLocalDraft()),
      );

      if (_secondsRemaining <= 0) {
        unawaited(_handleTimeExpired());
      } else {
        _startTimer();
      }

      if (recovered != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unsynced progress was recovered from this device. Syncing it to ExamTree now.',
            ),
          ),
        );
        unawaited(_saveSession(quiet: false));
      } else if (session.state != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved progress restored from ExamTree.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error;
        _initialising = false;
      });
    }
  }

  void _startTimer''',
)

regex_once(
    r"  void _startTimer\(\) \{.*?\n  \}\n\n  void _showTimerWarning",
    '''  void _startTimer() {
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final threshold = currentTimerWarningThreshold(
        secondsRemaining: _secondsRemaining,
        alreadyShown: _shownTimerWarnings,
      );
      if (threshold != null) _showTimerWarning(threshold);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        unawaited(_handleTimeExpired());
        return;
      }

      final previous = _secondsRemaining;
      final current = previous - 1;
      setState(() {
        _secondsRemaining = current;
        if (_isForeground) {
          final questionId = _questions[_currentIndex].id.toString();
          _questionTimeSecondsById[questionId] =
              (_questionTimeSecondsById[questionId] ?? 0) + 1;
        }
      });

      final threshold = crossedTimerWarningThreshold(
        previousSeconds: previous,
        currentSeconds: current,
        alreadyShown: _shownTimerWarnings,
      );
      if (threshold != null) _showTimerWarning(threshold);

      if (current <= 0) {
        timer.cancel();
        unawaited(_handleTimeExpired());
      }
    });
  }

  void _showTimerWarning''',
)

replace_once(
    "    if (_timeExpired || _submitting) return;\n    setState(() => _timeExpired = true);",
    "    if ((_timeExpired && _submissionPending) || _submitting) return;\n"
    "    setState(() {\n"
    "      _timeExpired = true;\n"
    "      _submissionPending = true;\n"
    "    });",
)

replace_once(
    "    if (_states[_currentIndex].status == QuestionStatus.notVisited) {\n      _states[_currentIndex].status = QuestionStatus.notAnswered;\n    }\n  }\n\n  AttemptSessionState _buildState()",
    "    if (_states[_currentIndex].status == QuestionStatus.notVisited) {\n"
    "      _states[_currentIndex].status = QuestionStatus.notAnswered;\n"
    "    }\n"
    "    _questionTimeSecondsById\n"
    "      ..clear()\n"
    "      ..addAll(state.questionTimeSecondsById);\n"
    "  }\n\n"
    "  AttemptSessionState _buildState()",
)

replace_once(
    "      visitedQuestionIds: visited,\n    );",
    "      visitedQuestionIds: visited,\n"
    "      questionTimeSecondsById: Map<String, int>.unmodifiable(\n"
    "        _questionTimeSecondsById,\n"
    "      ),\n"
    "    );",
)

replace_once(
    "  void _scheduleAutosave() {\n    _autosaveDebounce?.cancel();",
    "  void _scheduleAutosave() {\n"
    "    unawaited(_persistLocalDraft());\n"
    "    _autosaveDebounce?.cancel();",
)

regex_once(
    r"  Future<bool> _saveSession\(\{bool quiet = true\}\) async \{.*?\n  \}\n\n  Future<void> _requestSubmit",
    '''  Future<bool> _saveSession({bool quiet = true}) async {
    final attemptId = _attemptId;
    if (attemptId == null || _initialising) return false;

    await _persistLocalDraft();
    final activeSave = _activeSave;
    if (activeSave != null) {
      _saveQueued = true;
      return activeSave;
    }

    final future = _performSaveCycle(attemptId: attemptId, quiet: quiet);
    _activeSave = future;
    try {
      return await future;
    } finally {
      if (identical(_activeSave, future)) _activeSave = null;
    }
  }

  Future<bool> _performSaveCycle({
    required String attemptId,
    required bool quiet,
  }) async {
    var success = true;
    do {
      _saveQueued = false;
      if (mounted) setState(() => _syncing = true);

      try {
        final session = await ref
            .read(attemptSessionRepositoryProvider)
            .saveSession(
              attemptId: attemptId,
              expectedRevision: _revision,
              state: _buildState(),
            );
        if (!mounted) return false;
        setState(() {
          _revision = session.revision;
          _lastSavedAt = session.savedAt;
          _syncFailed = false;
        });
        await _persistLocalDraft();
      } on AttemptSessionConflict catch (conflict) {
        if (!mounted) return false;
        setState(() {
          _revision = conflict.latestSession.revision;
          _lastSavedAt = conflict.latestSession.savedAt;
          _syncFailed = false;
          if (conflict.latestSession.state != null) {
            _restoreState(conflict.latestSession.state!);
          }
        });
        await _persistLocalDraft();
        _saveQueued = false;
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This test changed on another device. The latest server progress was loaded.',
            ),
          ),
        );
      } catch (error) {
        if (!mounted) return false;
        setState(() => _syncFailed = true);
        success = false;
        if (!quiet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Progress is saved on this device but has not reached ExamTree yet.',
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _syncing = false);
      }
    } while (_saveQueued && success && mounted);

    return success;
  }

  Future<void> _requestSubmit''',
)

regex_once(
    r"  Future<void> _submitAttempt\(\{bool autoSubmit = false\}\) async \{.*?\n  \}\n\n  Future<void> _confirmExit",
    '''  Future<void> _submitAttempt({bool autoSubmit = false}) async {
    if (_submitting || _attemptId == null) return;
    setState(() {
      _submitting = true;
      if (autoSubmit) {
        _timeExpired = true;
        _submissionPending = true;
      }
    });

    var completed = false;
    try {
      final saved = await _saveSession(quiet: autoSubmit);
      if (!mounted) return;
      if (!saved && !autoSubmit) return;

      final responses = _questions.asMap().entries.map((entry) {
        final questionId = entry.value.id;
        return AttemptResponsePayload(
          questionId: questionId,
          selectedOption: _states[entry.key].selectedOptionIndex,
          timeTaken: _questionTimeSecondsById[questionId.toString()] ?? 0,
        );
      }).toList();
      final flags = <String, bool>{
        for (var i = 0; i < _questions.length; i++)
          _questions[i].id.toString(): _isMarked(_states[i].status),
      };

      final response = await ref
          .read(attemptSessionRepositoryProvider)
          .submitAttempt(
            attemptId: _attemptId!,
            testId: widget.exam.id,
            timeSpentMinutes:
                ((_initialDurationSeconds - _secondsRemaining) / 60).round(),
            responses: responses,
            flags: flags,
          );
      if (!mounted) return;

      completed = true;
      _timer?.cancel();
      _periodicAutosave?.cancel();
      _localCheckpoint?.cancel();
      await _deleteLocalDraft();
      ref.invalidate(userResultsProvider);
      if (!mounted) return;
      context.replace(
        '/review',
        extra: response.attemptId.isEmpty ? _attemptId! : response.attemptId,
      );
    } catch (_) {
      if (!mounted) return;
      await _persistLocalDraft();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoSubmit
                ? 'Time is over. Your answers are safe on this device; reconnect and retry submission.'
                : 'Unable to submit right now. Your answers remain saved; try again.',
          ),
        ),
      );
    } finally {
      if (mounted && !completed) {
        setState(() {
          _submitting = false;
          if (!autoSubmit) _submissionPending = false;
        });
      }
    }
  }

  Future<void> _confirmExit''',
)

insert_anchor = "  @override\n  Widget build(BuildContext context) {\n    if (_initialising || _startupError != null) {"
replace_once(
    insert_anchor,
    '''  Widget _buildSubmissionStatus(ThemeData theme) {
    if (_submitting) {
      return Material(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _timeExpired ? 'Time expired — submitting your test' : 'Submitting your test',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Time expired. Answers are locked and submission is pending.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => unawaited(_submitAttempt(autoSubmit: true)),
              child: Text(
                'Retry submit',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialising || _startupError != null) {''',
)

old_status = '''            if (_timeExpired || _submitting)
              Material(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _timeExpired
                            ? 'Time expired — submitting your test'
                            : 'Submitting your test',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),'''
replace_once(
    old_status,
    "            if (_timeExpired || _submitting) _buildSubmissionStatus(theme),",
)

screen_path.write_text(text)

# Make the sync banner truthful about the local durability layer.
dialog_path = Path('lib/features/test_attempt/presentation/widgets/test_attempt_dialogs.dart')
dialog = dialog_path.read_text()
old = """                      : lastSavedAt == null
                          ? 'Progress is not saved.'
                          : 'Latest changes are not saved. Last saved earlier.',"""
new = """                      : lastSavedAt == null
                          ? 'Progress is saved on this device and waiting to sync.'
                          : 'Latest changes are saved on this device but not synced to ExamTree yet.',"""
if dialog.count(old) != 1:
    raise SystemExit('sync banner message anchor not found exactly once')
dialog_path.write_text(dialog.replace(old, new, 1))

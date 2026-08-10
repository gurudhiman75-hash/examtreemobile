from pathlib import Path

path = Path('lib/features/test_attempt/presentation/canonical_test_attempt_screen.dart')
text = path.read_text()

old = """      final userId = _currentUserId;
      final localDraft = userId == null || userId.isEmpty
          ? null
          : await ref.read(attemptDraftStoreProvider).read(
                userId: userId,
                testId: widget.exam.id,
              );
      final session = await ref
"""
new = """      final userId = _currentUserId;
      LocalAttemptDraft? localDraft;
      if (userId != null && userId.isNotEmpty) {
        try {
          localDraft = await ref.read(attemptDraftStoreProvider).read(
                userId: userId,
                testId: widget.exam.id,
              );
        } catch (_) {
          // A local-cache problem must never prevent a canonical server resume.
        }
      }
      final session = await ref
"""
if text.count(old) != 1:
    raise SystemExit('local draft startup anchor mismatch')
text = text.replace(old, new, 1)

old = """    final activeSave = _activeSave;
    if (activeSave != null) {
      _saveQueued = true;
      return activeSave;
    }
"""
new = """    final activeSave = _activeSave;
    if (activeSave != null) {
      _saveQueued = true;
      final result = await activeSave;
      if (_saveQueued && result && mounted) {
        return _saveSession(quiet: quiet);
      }
      return result;
    }
"""
if text.count(old) != 1:
    raise SystemExit('active save queue anchor mismatch')
text = text.replace(old, new, 1)

path.write_text(text)

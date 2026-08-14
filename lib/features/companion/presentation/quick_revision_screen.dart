import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/daily_companion.dart';
import 'providers/daily_companion_providers.dart';

class QuickRevisionScreen extends ConsumerStatefulWidget {
  const QuickRevisionScreen({super.key, required this.minutes});
  final int minutes;

  @override
  ConsumerState<QuickRevisionScreen> createState() => _QuickRevisionScreenState();
}

class _QuickRevisionScreenState extends ConsumerState<QuickRevisionScreen> {
  List<RevisionItem>? _items;
  int _index = 0;
  bool _revealed = false;
  bool _saving = false;
  bool _done = false;

  Future<void> _record(RevisionItem item, bool remembered) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(dailyCompanionControllerProvider).recordOutcome(
            userId: user.uid,
            item: item,
            remembered: remembered,
            reviewedAt: DateTime.now(),
          );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _revealed = false;
        if (_items == null || _index + 1 >= _items!.length) {
          _done = true;
        } else {
          _index++;
        }
      });
      ref.invalidate(dailyCompanionSnapshotProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save this review.')),
      );
    }
  }

  void _finish(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/daily');
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(dailyCompanionSnapshotProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${widget.minutes}-minute revision')),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Revision queue unavailable.')),
        data: (data) {
          _items ??= selectQuickRevisionItems(
            data.items,
            minutes: widget.minutes,
            now: DateTime.now(),
          );
          if (_done || _items!.isEmpty) {
            return Center(
              child: FilledButton.icon(
                onPressed: () => _finish(context),
                icon: const Icon(Icons.task_alt_rounded),
                label: Text(_items!.isEmpty ? 'Nothing due — Done' : 'Session complete'),
              ),
            );
          }

          final item = _items![_index];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LinearProgressIndicator(value: (_index + 1) / _items!.length),
              const SizedBox(height: 20),
              Text(
                item.reasons.map((reason) => reason.label).join(' • '),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                item.questionText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              ...List.generate(item.options.length, (i) {
                final correct = _revealed && i == item.correctIndex;
                final wrong = _revealed && i == item.selectedIndex && !correct;
                return Card(
                  child: ListTile(
                    leading: Text(String.fromCharCode(65 + i)),
                    title: Text(item.options[i]),
                    trailing: correct
                        ? const Icon(Icons.check_circle_rounded)
                        : wrong
                            ? const Icon(Icons.close_rounded)
                            : null,
                  ),
                );
              }),
              const SizedBox(height: 12),
              if (!_revealed)
                FilledButton(
                  onPressed: () => setState(() => _revealed = true),
                  child: const Text('Show answer'),
                )
              else ...[
                Text(
                  item.explanation.trim().isEmpty
                      ? 'No explanation was stored with this result.'
                      : item.explanation,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => _record(item, false),
                        child: const Text('Review again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : () => _record(item, true),
                        child: const Text('Got it'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

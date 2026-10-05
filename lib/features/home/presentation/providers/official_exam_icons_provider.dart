import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const officialExamIconsStorageFolder = 'Icons for seriesbetc';

final officialExamIconUrlsProvider =
    FutureProvider<Map<String, String>>((ref) async {
  try {
    final root =
        FirebaseStorage.instance.ref().child(officialExamIconsStorageFolder);
    final result = await root.listAll();
    final urls = <String, String>{};

    for (final item in result.items) {
      final url = await item.getDownloadURL();
      final normalized = _normalizeIconKey(item.name);
      if (normalized.isNotEmpty) {
        urls[normalized] = url;
      }
    }

    return urls;
  } catch (_) {
    return const <String, String>{};
  }
});

String officialIconForExamFamily({
  required String code,
  required String name,
  required Map<String, String> urls,
}) {
  if (urls.isEmpty) return '';

  final candidates = <String>{
    _normalizeIconKey(code),
    _normalizeIconKey(name),
    ..._aliasesFor(code + ' ' + name),
  }..removeWhere((value) => value.isEmpty);

  for (final candidate in candidates) {
    final exact = urls[candidate];
    if (exact != null && exact.isNotEmpty) return exact;
  }

  for (final entry in urls.entries) {
    for (final candidate in candidates) {
      if (entry.key.contains(candidate) || candidate.contains(entry.key)) {
        return entry.value;
      }
    }
  }

  return '';
}

Set<String> _aliasesFor(String value) {
  final key = value.toLowerCase();
  final aliases = <String>{};

  if (key.contains('punjab')) {
    aliases.addAll({'punjab', 'punjabgovt', 'punjabgovernment'});
  }
  if (key.contains('ssc')) {
    aliases.addAll({'ssc', 'staffselectioncommission'});
  }
  if (key.contains('bank')) {
    aliases.addAll({'bank', 'banking', 'ibps'});
  }
  if (key.contains('rail')) {
    aliases.addAll({'railway', 'rrb', 'rail'});
  }
  if (key.contains('teach')) {
    aliases.addAll({'teaching', 'teacher', 'education'});
  }
  if (key.contains('defen') || key.contains('army') || key.contains('navy')) {
    aliases.addAll({'defence', 'defense', 'army'});
  }
  if (key.contains('pcs') || key.contains('state')) {
    aliases.addAll({'statepcs', 'pcs'});
  }
  if (key.contains('other')) {
    aliases.addAll({'other', 'otherexams'});
  }

  return aliases;
}

String _normalizeIconKey(String value) {
  final dot = value.lastIndexOf('.');
  final base = dot > 0 ? value.substring(0, dot) : value;
  return base.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

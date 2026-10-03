import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/exam_api_dto.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/exam_catalog.dart';

final examCatalogProvider = FutureProvider<ExamCatalogSnapshot>((ref) async {
  final client = ref.watch(apiClientProvider);
  final categoriesResponse =
      await client.dio.get<List<dynamic>>('/categories');
  final subcategoriesResponse =
      await client.dio.get<List<dynamic>>('/subcategories');
  final seriesResponse =
      await client.dio.get<Map<String, dynamic>>('/test-series');
  final seriesBody = seriesResponse.data;

  final categories = (categoriesResponse.data ?? const <dynamic>[])
      .whereType<Map>()
      .map((item) => CategoryDto.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);

  final subcategories =
      (subcategoriesResponse.data ?? const <dynamic>[])
      .whereType<Map>()
      .map((item) => SubcategoryDto.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);

  final rawSeries = seriesBody?['series'];
  final series = rawSeries is List
      ? rawSeries
          .whereType<Map>()
          .map(
            (item) =>
                ExamSeriesSummary.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.id.isNotEmpty && item.examCode.isNotEmpty)
          .toList(growable: false)
      : const <ExamSeriesSummary>[];

  String absoluteAssetUrl(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return '';
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme) return raw;

    final base = Uri.tryParse(client.dio.options.baseUrl);
    if (base == null) return raw;
    return base.resolve(raw).toString();
  }

  final categoryModels = categories
      .where((category) => category.id.trim().isNotEmpty)
      .map(
        (category) => ExamCatalogCategory(
          code: category.id.trim(),
          name: category.name.trim(),
          description: category.description.trim(),
          iconUrl: absoluteAssetUrl(category.icon),
          colorHex: category.color?.trim() ?? '',
          testCount: category.testsCount,
        ),
      )
      .toList()
    ..sort(
      (left, right) =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()),
    );

  final seriesByExam = <String, List<ExamSeriesSummary>>{};
  for (final item in series) {
    seriesByExam
        .putIfAbsent(item.examCode.trim().toLowerCase(), () => [])
        .add(item);
  }

  final examModels = subcategories
      .where(
        (exam) =>
            exam.id.trim().isNotEmpty && exam.categoryId.trim().isNotEmpty,
      )
      .map((exam) {
        final matching =
            seriesByExam[exam.id.trim().toLowerCase()] ?? const <ExamSeriesSummary>[];
        final testCount =
            matching.fold<int>(0, (sum, item) => sum + item.liveTestCount);
        return ExamCatalogExam(
          code: exam.id.trim(),
          familyCode: exam.categoryId.trim(),
          familyName: exam.categoryName.trim(),
          name: exam.name.trim(),
          description: exam.description.trim(),
          iconUrl: absoluteAssetUrl(exam.icon),
          languages: exam.languages,
          seriesCount: matching.length,
          testCount: testCount,
          primarySeriesId: matching.length == 1 ? matching.first.id : null,
        );
      })
      .toList()
    ..sort((left, right) {
      final family =
          left.familyName.toLowerCase().compareTo(right.familyName.toLowerCase());
      if (family != 0) return family;
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });

  return ExamCatalogSnapshot(
    categories: categoryModels,
    exams: examModels,
    series: series,
  );
});

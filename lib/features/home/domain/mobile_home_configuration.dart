class MobileHeroSlide {
  const MobileHeroSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaLabel,
    required this.destinationType,
    required this.destinationValue,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaLabel;
  final String destinationType;
  final String destinationValue;
  final bool isActive;
  final int sortOrder;

  factory MobileHeroSlide.fromJson(Map<String, dynamic> json) {
    return MobileHeroSlide(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      ctaLabel: json['ctaLabel']?.toString() ?? '',
      destinationType: json['destinationType']?.toString() ?? 'none',
      destinationValue: json['destinationValue']?.toString() ?? '',
      isActive: json['isActive'] != false,
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
    );
  }
}

class MobileFeaturedExamFamily {
  const MobileFeaturedExamFamily({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;

  factory MobileFeaturedExamFamily.fromJson(Map<String, dynamic> json) {
    return MobileFeaturedExamFamily(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class MobileFeaturedTestSeries {
  const MobileFeaturedTestSeries({
    required this.id,
    required this.code,
    required this.name,
    required this.examName,
    required this.testCount,
  });

  final String id;
  final String code;
  final String name;
  final String examName;
  final int testCount;

  factory MobileFeaturedTestSeries.fromJson(Map<String, dynamic> json) {
    return MobileFeaturedTestSeries(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      examName: json['examName']?.toString() ?? '',
      testCount: int.tryParse(json['testCount']?.toString() ?? '') ?? 0,
    );
  }
}

class MobileHomeConfiguration {
  const MobileHomeConfiguration({
    required this.heroSlides,
    required this.featuredExamFamilyIds,
    required this.featuredTestSeriesIds,
    required this.featuredExamFamilies,
    required this.featuredTestSeries,
    required this.sectionOrder,
  });

  final List<MobileHeroSlide> heroSlides;
  final List<String> featuredExamFamilyIds;
  final List<String> featuredTestSeriesIds;
  final List<MobileFeaturedExamFamily> featuredExamFamilies;
  final List<MobileFeaturedTestSeries> featuredTestSeries;
  final List<String> sectionOrder;

  static const fallback = MobileHomeConfiguration(
    heroSlides: <MobileHeroSlide>[],
    featuredExamFamilyIds: <String>[],
    featuredTestSeriesIds: <String>[],
    featuredExamFamilies: <MobileFeaturedExamFamily>[],
    featuredTestSeries: <MobileFeaturedTestSeries>[],
    sectionOrder: <String>[
      'hero',
      'exam_categories',
      'featured_test_series',
      'continue_learning',
    ],
  );

  factory MobileHomeConfiguration.fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? value) => value is List
        ? value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList()
        : const <String>[];

    final slidesRaw = json['heroSlides'];
    final slides = slidesRaw is List
        ? slidesRaw
            .whereType<Map>()
            .map((item) => MobileHeroSlide.fromJson(Map<String, dynamic>.from(item)))
            .where((slide) => slide.isActive && slide.title.trim().isNotEmpty)
            .toList()
        : <MobileHeroSlide>[];
    slides.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final requested = strings(json['sectionOrder']);
    const allowed = <String>[
      'hero',
      'exam_categories',
      'featured_test_series',
      'continue_learning',
    ];
    final order = <String>[
      ...requested.where(allowed.contains),
      ...allowed.where((section) => !requested.contains(section)),
    ];

    return MobileHomeConfiguration(
      heroSlides: slides,
      featuredExamFamilyIds: strings(json['featuredExamFamilyIds']),
      featuredTestSeriesIds: strings(json['featuredTestSeriesIds']),
      featuredExamFamilies: (json['featuredExamFamilies'] is List)
          ? (json['featuredExamFamilies'] as List)
              .whereType<Map>()
              .map((item) => MobileFeaturedExamFamily.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
              .toList()
          : const <MobileFeaturedExamFamily>[],
      featuredTestSeries: (json['featuredTestSeries'] is List)
          ? (json['featuredTestSeries'] as List)
              .whereType<Map>()
              .map((item) => MobileFeaturedTestSeries.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
              .toList()
          : const <MobileFeaturedTestSeries>[],
      sectionOrder: order,
    );
  }
}

class MobileHeroSlide {
  const MobileHeroSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.iconName,
    required this.iconUrl,
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
  final String iconName;
  final String iconUrl;
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
      iconName: json['iconName']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
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

class MobileHomeSectionSetting {
  const MobileHomeSectionSetting({
    this.title = '',
    this.subtitle = '',
    this.iconName = '',
    this.iconUrl = '',
    this.layout = '',
    this.isVisible = true,
  });

  final String title;
  final String subtitle;
  final String iconName;
  final String iconUrl;
  final String layout;
  final bool isVisible;

  factory MobileHomeSectionSetting.fromJson(Map<String, dynamic> json) {
    return MobileHomeSectionSetting(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      layout: json['layout']?.toString() ?? '',
      isVisible: json['isVisible'] != false,
    );
  }
}

class MobileHomeItemOverride {
  const MobileHomeItemOverride({
    this.title = '',
    this.subtitle = '',
    this.badge = '',
    this.iconName = '',
    this.iconUrl = '',
    this.imageUrl = '',
    this.hidden = false,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String iconName;
  final String iconUrl;
  final String imageUrl;
  final bool hidden;

  factory MobileHomeItemOverride.fromJson(Map<String, dynamic> json) {
    return MobileHomeItemOverride(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      hidden: json['hidden'] == true,
    );
  }
}

class MobileHomeCard {
  const MobileHomeCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.iconName,
    required this.iconUrl,
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
  final String badge;
  final String iconName;
  final String iconUrl;
  final String imageUrl;
  final String ctaLabel;
  final String destinationType;
  final String destinationValue;
  final bool isActive;
  final int sortOrder;

  factory MobileHomeCard.fromJson(Map<String, dynamic> json) {
    return MobileHomeCard(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      ctaLabel: json['ctaLabel']?.toString() ?? '',
      destinationType: json['destinationType']?.toString() ?? 'none',
      destinationValue: json['destinationValue']?.toString() ?? '',
      isActive: json['isActive'] != false,
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
    );
  }
}

class MobileCustomHomeSection {
  const MobileCustomHomeSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.iconUrl,
    required this.layout,
    required this.isVisible,
    required this.sortOrder,
    required this.cards,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String iconUrl;
  final String layout;
  final bool isVisible;
  final int sortOrder;
  final List<MobileHomeCard> cards;

  factory MobileCustomHomeSection.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] is List)
        ? (json['cards'] as List)
            .whereType<Map>()
            .map((item) => MobileHomeCard.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.isActive && item.title.trim().isNotEmpty)
            .toList()
        : <MobileHomeCard>[];
    cards.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return MobileCustomHomeSection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      layout: json['layout']?.toString() ?? 'horizontal',
      isVisible: json['isVisible'] != false,
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      cards: cards,
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
    required this.customSections,
    required this.sectionSettings,
    required this.itemOverrides,
    required this.sectionOrder,
  });

  final List<MobileHeroSlide> heroSlides;
  final List<String> featuredExamFamilyIds;
  final List<String> featuredTestSeriesIds;
  final List<MobileFeaturedExamFamily> featuredExamFamilies;
  final List<MobileFeaturedTestSeries> featuredTestSeries;
  final List<MobileCustomHomeSection> customSections;
  final Map<String, MobileHomeSectionSetting> sectionSettings;
  final Map<String, MobileHomeItemOverride> itemOverrides;
  final List<String> sectionOrder;

  static const fallback = MobileHomeConfiguration(
    heroSlides: <MobileHeroSlide>[],
    featuredExamFamilyIds: <String>[],
    featuredTestSeriesIds: <String>[],
    featuredExamFamilies: <MobileFeaturedExamFamily>[],
    featuredTestSeries: <MobileFeaturedTestSeries>[],
    customSections: <MobileCustomHomeSection>[],
    sectionSettings: <String, MobileHomeSectionSetting>{},
    itemOverrides: <String, MobileHomeItemOverride>{},
    sectionOrder: <String>[
      'hero',
      'exam_categories',
      'featured_test_series',
      'continue_learning',
      'recommended_learning',
      'current_affairs',
      'today_goal',
    ],
  );

  factory MobileHomeConfiguration.fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? value) => value is List
        ? value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList()
        : const <String>[];

    Map<String, T> mapped<T>(
      Object? value,
      T Function(Map<String, dynamic>) parser,
    ) {
      if (value is! Map) return <String, T>{};
      final result = <String, T>{};
      for (final entry in value.entries) {
        if (entry.value is! Map) continue;
        result[entry.key.toString()] =
            parser(Map<String, dynamic>.from(entry.value as Map));
      }
      return result;
    }

    final slidesRaw = json['heroSlides'];
    final slides = slidesRaw is List
        ? slidesRaw
            .whereType<Map>()
            .map((item) => MobileHeroSlide.fromJson(Map<String, dynamic>.from(item)))
            .where((slide) => slide.isActive && slide.title.trim().isNotEmpty)
            .toList()
        : <MobileHeroSlide>[];
    slides.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final customSections = (json['customSections'] is List)
        ? (json['customSections'] as List)
            .whereType<Map>()
            .map((item) => MobileCustomHomeSection.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .where((item) =>
                item.id.trim().isNotEmpty &&
                item.title.trim().isNotEmpty &&
                item.isVisible)
            .toList()
        : <MobileCustomHomeSection>[];
    customSections.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final customIds = customSections.map((section) => section.id).toSet();
    final requested = strings(json['sectionOrder']);
    const standard = <String>[
      'hero',
      'exam_categories',
      'featured_test_series',
      'continue_learning',
      'recommended_learning',
      'current_affairs',
      'today_goal',
    ];
    final order = <String>[
      ...requested.where((section) =>
          standard.contains(section) || customIds.contains(section)),
      ...standard.where((section) => !requested.contains(section)),
      ...customSections
          .map((section) => section.id)
          .where((section) => !requested.contains(section)),
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
      customSections: customSections,
      sectionSettings: mapped(
        json['sectionSettings'],
        MobileHomeSectionSetting.fromJson,
      ),
      itemOverrides: mapped(
        json['itemOverrides'],
        MobileHomeItemOverride.fromJson,
      ),
      sectionOrder: order,
    );
  }

  MobileHomeSectionSetting settingFor(String id) =>
      sectionSettings[id] ?? const MobileHomeSectionSetting();

  MobileHomeItemOverride overrideFor(String id) =>
      itemOverrides[id] ?? const MobileHomeItemOverride();
}

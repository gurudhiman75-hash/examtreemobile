class MobileContentPlanItem {
  const MobileContentPlanItem({
    required this.id,
    required this.slotKey,
    required this.entityType,
    required this.entityId,
    required this.displayLabel,
    required this.badgeText,
    required this.languageCode,
    required this.sortOrder,
  });

  final String id;
  final String slotKey;
  final String entityType;
  final String entityId;
  final String displayLabel;
  final String badgeText;
  final String languageCode;
  final int sortOrder;

  factory MobileContentPlanItem.fromJson(Map<String, dynamic> json) {
    return MobileContentPlanItem(
      id: json['id']?.toString() ?? '',
      slotKey: json['slotKey']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
      displayLabel: json['displayLabel']?.toString() ??
          json['labelOverride']?.toString() ??
          'Featured content',
      badgeText: json['badgeText']?.toString() ?? '',
      languageCode: json['languageCode']?.toString() ?? '',
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
    );
  }
}

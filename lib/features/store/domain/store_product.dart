class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.currency,
    required this.listPriceMinor,
    required this.salePriceMinor,
    required this.validityDays,
    required this.saleStartAt,
    required this.saleEndAt,
    required this.testCount,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final String currency;
  final int listPriceMinor;
  final int salePriceMinor;
  final int? validityDays;
  final DateTime? saleStartAt;
  final DateTime? saleEndAt;
  final int testCount;

  bool get hasCanonicalDiscount =>
      listPriceMinor > salePriceMinor && salePriceMinor >= 0;

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    final id = _requiredString(json['id'], 'id');
    final title = _requiredString(json['title'], 'title');
    final currency = _requiredString(json['currency'], 'currency').toUpperCase();
    final listPriceMinor = _requiredNonNegativeInt(
      json['listPriceMinor'],
      'listPriceMinor',
    );
    final salePriceMinor = _requiredNonNegativeInt(
      json['salePriceMinor'],
      'salePriceMinor',
    );

    return StoreProduct(
      id: id,
      code: json['code']?.toString().trim() ?? '',
      title: title,
      description: json['description']?.toString().trim() ?? '',
      currency: currency,
      listPriceMinor: listPriceMinor,
      salePriceMinor: salePriceMinor,
      validityDays: _optionalNonNegativeInt(json['validityDays']),
      saleStartAt: _optionalDateTime(json['saleStartAt']),
      saleEndAt: _optionalDateTime(json['saleEndAt']),
      testCount: _optionalNonNegativeInt(json['testCount']) ?? 0,
    );
  }
}

String _requiredString(Object? value, String field) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) throw FormatException('Missing $field');
  return text;
}

int _requiredNonNegativeInt(Object? value, String field) {
  final parsed = _optionalNonNegativeInt(value);
  if (parsed == null) throw FormatException('Invalid $field');
  return parsed;
}

int? _optionalNonNegativeInt(Object? value) {
  if (value == null) return null;
  final parsed = value is num ? value.toInt() : int.tryParse(value.toString());
  if (parsed == null || parsed < 0) return null;
  return parsed;
}

DateTime? _optionalDateTime(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  return DateTime.tryParse(text)?.toUtc();
}

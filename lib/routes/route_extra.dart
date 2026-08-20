String? readRequiredRouteId(Object? extra, {Uri? uri}) {
  final queryValue = uri?.queryParameters['id']?.trim();
  if (queryValue != null && queryValue.isNotEmpty) return queryValue;

  if (extra is! String) return null;
  final value = extra.trim();
  return value.isEmpty ? null : value;
}

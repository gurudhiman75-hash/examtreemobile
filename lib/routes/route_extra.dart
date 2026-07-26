String? readRequiredRouteId(Object? extra) {
  if (extra is! String) return null;
  final value = extra.trim();
  return value.isEmpty ? null : value;
}

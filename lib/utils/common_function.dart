List<dynamic> filterListByText(List<dynamic> list, String search) {
  if (search.trim().isEmpty || list.isEmpty) return [];
  final query = search.toLowerCase();
  bool matches(dynamic value) {
    if (value == null) return false;
    if (value is String) {
      return value.toLowerCase().contains(query);
    }
    if (value is Map) {
      return value.values.any(matches);
    }
    if (value is List) {
      return value.any(matches);
    }
    return value.toString().toLowerCase().contains(query);
  }

  final filtered =
      list.where((item) {
        return item.values.any(matches);
      }).toList();

  return filtered;
}

/// A field the user's cached list can be sorted by.
enum ListSortField {
  lastUpdated("last_updated", "Last Updated", true),
  score("score", "Score", true),
  title("title", "Title", false);

  const ListSortField(this.storageValue, this.label, this.defaultDescending);

  /// The value persisted in the local store.
  final String storageValue;

  /// A human-readable label.
  final String label;

  /// The direction used when this field is first selected.
  final bool defaultDescending;

  static ListSortField fromStorageValue(String? value) {
    return values.firstWhere(
      (ListSortField field) => field.storageValue == value,
      orElse: () => ListSortField.lastUpdated,
    );
  }
}

/// A chosen sort field and direction.
class ListSort {
  const ListSort({required this.field, required this.descending});

  final ListSortField field;
  final bool descending;

  static const ListSort defaultSort =
      ListSort(field: ListSortField.lastUpdated, descending: true);

  ListSort toggled() => ListSort(field: field, descending: !descending);

  String encode() => "${field.storageValue}:${descending ? "desc" : "asc"}";

  static ListSort decode(String? value, {required ListSort fallback}) {
    final List<String> parts = (value ?? "").split(":");
    if (parts.length != 2) return fallback;
    return ListSort(
      field: ListSortField.fromStorageValue(parts[0]),
      descending: parts[1] != "asc",
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ListSort && other.field == field && other.descending == descending;

  @override
  int get hashCode => Object.hash(field, descending);

  @override
  String toString() => encode();
}

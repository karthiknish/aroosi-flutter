part of 'package:aroosi_flutter/features/profiles/models.dart';

class PagedResponse<T> {
  const PagedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    this.nextPage,
    this.nextCursor,
    bool? hasMore,
  }) : _hasMoreOverride = hasMore;

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;
  final int? nextPage;
  final String? nextCursor;
  final bool? _hasMoreOverride;

  bool get hasMore {
    if (_hasMoreOverride != null) {
      return _hasMoreOverride!; // ignore: unnecessary_non_null_assertion
    }
    if (nextCursor != null && nextCursor!.isNotEmpty) return true;
    final np = nextPage;
    if (np != null) return np > page;
    return items.length < total;
  }
}

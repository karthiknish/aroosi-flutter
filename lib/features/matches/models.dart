import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:aroosi_flutter/features/profiles/models.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class Match with _$Match {
  const factory Match({
    required String id,
    required List<String> participantIDs,
    required DateTime createdAt,
    required DateTime lastUpdatedAt,
    String? lastMessagePreview,
    @Default(0) int totalMessages,
    @Default(false) bool isActive,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
}

@freezed
class MatchListItem with _$MatchListItem {
  const factory MatchListItem({
    required String id,
    required Match match,
    @JsonKey(ignore: true) ProfileSummary? counterpartProfile,
    @Default(0) int unreadCount,
  }) = _MatchListItem;

  factory MatchListItem.fromJson(Map<String, dynamic> json) => _$MatchListItemFromJson(json);
}

extension MatchListItemExtensions on MatchListItem {
  String? get lastMessagePreview => match.lastMessagePreview;
  DateTime get lastUpdatedAt => match.lastUpdatedAt;
}

@freezed
class MatchesState with _$MatchesState {
  const factory MatchesState({
    @Default([]) List<MatchListItem> items,
    @Default(false) bool isLoading,
    String? error,
  }) = _MatchesState;

  factory MatchesState.fromJson(Map<String, dynamic> json) => _$MatchesStateFromJson(json);
}

extension MatchesStateExtensions on MatchesState {
  bool get isEmpty => !isLoading && error == null && items.isEmpty;
}

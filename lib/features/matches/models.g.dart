// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchImpl _$$MatchImplFromJson(Map<String, dynamic> json) => _$MatchImpl(
  id: json['id'] as String,
  participantIDs: (json['participantIDs'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
  lastMessagePreview: json['lastMessagePreview'] as String?,
  totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? false,
);

Map<String, dynamic> _$$MatchImplToJson(_$MatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participantIDs': instance.participantIDs,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
      'lastMessagePreview': instance.lastMessagePreview,
      'totalMessages': instance.totalMessages,
      'isActive': instance.isActive,
    };

_$MatchListItemImpl _$$MatchListItemImplFromJson(Map<String, dynamic> json) =>
    _$MatchListItemImpl(
      id: json['id'] as String,
      match: Match.fromJson(json['match'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MatchListItemImplToJson(_$MatchListItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'match': instance.match,
      'unreadCount': instance.unreadCount,
    };

_$MatchesStateImpl _$$MatchesStateImplFromJson(Map<String, dynamic> json) =>
    _$MatchesStateImpl(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => MatchListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$MatchesStateImplToJson(_$MatchesStateImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };

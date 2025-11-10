// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Match _$MatchFromJson(Map<String, dynamic> json) {
  return _Match.fromJson(json);
}

/// @nodoc
mixin _$Match {
  String get id => throw _privateConstructorUsedError;
  List<String> get participantIDs => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastUpdatedAt => throw _privateConstructorUsedError;
  String? get lastMessagePreview => throw _privateConstructorUsedError;
  int get totalMessages => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Match to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchCopyWith<Match> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchCopyWith<$Res> {
  factory $MatchCopyWith(Match value, $Res Function(Match) then) =
      _$MatchCopyWithImpl<$Res, Match>;
  @useResult
  $Res call({
    String id,
    List<String> participantIDs,
    DateTime createdAt,
    DateTime lastUpdatedAt,
    String? lastMessagePreview,
    int totalMessages,
    bool isActive,
  });
}

/// @nodoc
class _$MatchCopyWithImpl<$Res, $Val extends Match>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participantIDs = null,
    Object? createdAt = null,
    Object? lastUpdatedAt = null,
    Object? lastMessagePreview = freezed,
    Object? totalMessages = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            participantIDs: null == participantIDs
                ? _value.participantIDs
                : participantIDs // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastUpdatedAt: null == lastUpdatedAt
                ? _value.lastUpdatedAt
                : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastMessagePreview: freezed == lastMessagePreview
                ? _value.lastMessagePreview
                : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalMessages: null == totalMessages
                ? _value.totalMessages
                : totalMessages // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchImplCopyWith<$Res> implements $MatchCopyWith<$Res> {
  factory _$$MatchImplCopyWith(
    _$MatchImpl value,
    $Res Function(_$MatchImpl) then,
  ) = __$$MatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<String> participantIDs,
    DateTime createdAt,
    DateTime lastUpdatedAt,
    String? lastMessagePreview,
    int totalMessages,
    bool isActive,
  });
}

/// @nodoc
class __$$MatchImplCopyWithImpl<$Res>
    extends _$MatchCopyWithImpl<$Res, _$MatchImpl>
    implements _$$MatchImplCopyWith<$Res> {
  __$$MatchImplCopyWithImpl(
    _$MatchImpl _value,
    $Res Function(_$MatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participantIDs = null,
    Object? createdAt = null,
    Object? lastUpdatedAt = null,
    Object? lastMessagePreview = freezed,
    Object? totalMessages = null,
    Object? isActive = null,
  }) {
    return _then(
      _$MatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        participantIDs: null == participantIDs
            ? _value._participantIDs
            : participantIDs // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastUpdatedAt: null == lastUpdatedAt
            ? _value.lastUpdatedAt
            : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastMessagePreview: freezed == lastMessagePreview
            ? _value.lastMessagePreview
            : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalMessages: null == totalMessages
            ? _value.totalMessages
            : totalMessages // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchImpl implements _Match {
  const _$MatchImpl({
    required this.id,
    required final List<String> participantIDs,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.lastMessagePreview,
    this.totalMessages = 0,
    this.isActive = false,
  }) : _participantIDs = participantIDs;

  factory _$MatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchImplFromJson(json);

  @override
  final String id;
  final List<String> _participantIDs;
  @override
  List<String> get participantIDs {
    if (_participantIDs is EqualUnmodifiableListView) return _participantIDs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIDs);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime lastUpdatedAt;
  @override
  final String? lastMessagePreview;
  @override
  @JsonKey()
  final int totalMessages;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Match(id: $id, participantIDs: $participantIDs, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, lastMessagePreview: $lastMessagePreview, totalMessages: $totalMessages, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(
              other._participantIDs,
              _participantIDs,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt) &&
            (identical(other.lastMessagePreview, lastMessagePreview) ||
                other.lastMessagePreview == lastMessagePreview) &&
            (identical(other.totalMessages, totalMessages) ||
                other.totalMessages == totalMessages) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_participantIDs),
    createdAt,
    lastUpdatedAt,
    lastMessagePreview,
    totalMessages,
    isActive,
  );

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      __$$MatchImplCopyWithImpl<_$MatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchImplToJson(this);
  }
}

abstract class _Match implements Match {
  const factory _Match({
    required final String id,
    required final List<String> participantIDs,
    required final DateTime createdAt,
    required final DateTime lastUpdatedAt,
    final String? lastMessagePreview,
    final int totalMessages,
    final bool isActive,
  }) = _$MatchImpl;

  factory _Match.fromJson(Map<String, dynamic> json) = _$MatchImpl.fromJson;

  @override
  String get id;
  @override
  List<String> get participantIDs;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastUpdatedAt;
  @override
  String? get lastMessagePreview;
  @override
  int get totalMessages;
  @override
  bool get isActive;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchListItem _$MatchListItemFromJson(Map<String, dynamic> json) {
  return _MatchListItem.fromJson(json);
}

/// @nodoc
mixin _$MatchListItem {
  String get id => throw _privateConstructorUsedError;
  Match get match => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  ProfileSummary? get counterpartProfile => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  /// Serializes this MatchListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchListItemCopyWith<MatchListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchListItemCopyWith<$Res> {
  factory $MatchListItemCopyWith(
    MatchListItem value,
    $Res Function(MatchListItem) then,
  ) = _$MatchListItemCopyWithImpl<$Res, MatchListItem>;
  @useResult
  $Res call({
    String id,
    Match match,
    @JsonKey(includeFromJson: false, includeToJson: false)
    ProfileSummary? counterpartProfile,
    int unreadCount,
  });

  $MatchCopyWith<$Res> get match;
}

/// @nodoc
class _$MatchListItemCopyWithImpl<$Res, $Val extends MatchListItem>
    implements $MatchListItemCopyWith<$Res> {
  _$MatchListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? match = null,
    Object? counterpartProfile = freezed,
    Object? unreadCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            match: null == match
                ? _value.match
                : match // ignore: cast_nullable_to_non_nullable
                      as Match,
            counterpartProfile: freezed == counterpartProfile
                ? _value.counterpartProfile
                : counterpartProfile // ignore: cast_nullable_to_non_nullable
                      as ProfileSummary?,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchCopyWith<$Res> get match {
    return $MatchCopyWith<$Res>(_value.match, (value) {
      return _then(_value.copyWith(match: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchListItemImplCopyWith<$Res>
    implements $MatchListItemCopyWith<$Res> {
  factory _$$MatchListItemImplCopyWith(
    _$MatchListItemImpl value,
    $Res Function(_$MatchListItemImpl) then,
  ) = __$$MatchListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    Match match,
    @JsonKey(includeFromJson: false, includeToJson: false)
    ProfileSummary? counterpartProfile,
    int unreadCount,
  });

  @override
  $MatchCopyWith<$Res> get match;
}

/// @nodoc
class __$$MatchListItemImplCopyWithImpl<$Res>
    extends _$MatchListItemCopyWithImpl<$Res, _$MatchListItemImpl>
    implements _$$MatchListItemImplCopyWith<$Res> {
  __$$MatchListItemImplCopyWithImpl(
    _$MatchListItemImpl _value,
    $Res Function(_$MatchListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? match = null,
    Object? counterpartProfile = freezed,
    Object? unreadCount = null,
  }) {
    return _then(
      _$MatchListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        match: null == match
            ? _value.match
            : match // ignore: cast_nullable_to_non_nullable
                  as Match,
        counterpartProfile: freezed == counterpartProfile
            ? _value.counterpartProfile
            : counterpartProfile // ignore: cast_nullable_to_non_nullable
                  as ProfileSummary?,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchListItemImpl implements _MatchListItem {
  const _$MatchListItemImpl({
    required this.id,
    required this.match,
    @JsonKey(includeFromJson: false, includeToJson: false)
    this.counterpartProfile,
    this.unreadCount = 0,
  });

  factory _$MatchListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchListItemImplFromJson(json);

  @override
  final String id;
  @override
  final Match match;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ProfileSummary? counterpartProfile;
  @override
  @JsonKey()
  final int unreadCount;

  @override
  String toString() {
    return 'MatchListItem(id: $id, match: $match, counterpartProfile: $counterpartProfile, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.match, match) || other.match == match) &&
            (identical(other.counterpartProfile, counterpartProfile) ||
                other.counterpartProfile == counterpartProfile) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, match, counterpartProfile, unreadCount);

  /// Create a copy of MatchListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchListItemImplCopyWith<_$MatchListItemImpl> get copyWith =>
      __$$MatchListItemImplCopyWithImpl<_$MatchListItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchListItemImplToJson(this);
  }
}

abstract class _MatchListItem implements MatchListItem {
  const factory _MatchListItem({
    required final String id,
    required final Match match,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final ProfileSummary? counterpartProfile,
    final int unreadCount,
  }) = _$MatchListItemImpl;

  factory _MatchListItem.fromJson(Map<String, dynamic> json) =
      _$MatchListItemImpl.fromJson;

  @override
  String get id;
  @override
  Match get match;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  ProfileSummary? get counterpartProfile;
  @override
  int get unreadCount;

  /// Create a copy of MatchListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchListItemImplCopyWith<_$MatchListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchesState _$MatchesStateFromJson(Map<String, dynamic> json) {
  return _MatchesState.fromJson(json);
}

/// @nodoc
mixin _$MatchesState {
  List<MatchListItem> get items => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this MatchesState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchesStateCopyWith<MatchesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchesStateCopyWith<$Res> {
  factory $MatchesStateCopyWith(
    MatchesState value,
    $Res Function(MatchesState) then,
  ) = _$MatchesStateCopyWithImpl<$Res, MatchesState>;
  @useResult
  $Res call({List<MatchListItem> items, bool isLoading, String? error});
}

/// @nodoc
class _$MatchesStateCopyWithImpl<$Res, $Val extends MatchesState>
    implements $MatchesStateCopyWith<$Res> {
  _$MatchesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<MatchListItem>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchesStateImplCopyWith<$Res>
    implements $MatchesStateCopyWith<$Res> {
  factory _$$MatchesStateImplCopyWith(
    _$MatchesStateImpl value,
    $Res Function(_$MatchesStateImpl) then,
  ) = __$$MatchesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MatchListItem> items, bool isLoading, String? error});
}

/// @nodoc
class __$$MatchesStateImplCopyWithImpl<$Res>
    extends _$MatchesStateCopyWithImpl<$Res, _$MatchesStateImpl>
    implements _$$MatchesStateImplCopyWith<$Res> {
  __$$MatchesStateImplCopyWithImpl(
    _$MatchesStateImpl _value,
    $Res Function(_$MatchesStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$MatchesStateImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<MatchListItem>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchesStateImpl implements _MatchesState {
  const _$MatchesStateImpl({
    final List<MatchListItem> items = const [],
    this.isLoading = false,
    this.error,
  }) : _items = items;

  factory _$MatchesStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchesStateImplFromJson(json);

  final List<MatchListItem> _items;
  @override
  @JsonKey()
  List<MatchListItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'MatchesState(items: $items, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchesStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    isLoading,
    error,
  );

  /// Create a copy of MatchesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchesStateImplCopyWith<_$MatchesStateImpl> get copyWith =>
      __$$MatchesStateImplCopyWithImpl<_$MatchesStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchesStateImplToJson(this);
  }
}

abstract class _MatchesState implements MatchesState {
  const factory _MatchesState({
    final List<MatchListItem> items,
    final bool isLoading,
    final String? error,
  }) = _$MatchesStateImpl;

  factory _MatchesState.fromJson(Map<String, dynamic> json) =
      _$MatchesStateImpl.fromJson;

  @override
  List<MatchListItem> get items;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of MatchesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchesStateImplCopyWith<_$MatchesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

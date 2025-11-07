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

MarriageIntention _$MarriageIntentionFromJson(Map<String, dynamic> json) {
  return _MarriageIntention.fromJson(json);
}

/// @nodoc
mixin _$MarriageIntention {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this MarriageIntention to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarriageIntention
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarriageIntentionCopyWith<MarriageIntention> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarriageIntentionCopyWith<$Res> {
  factory $MarriageIntentionCopyWith(
    MarriageIntention value,
    $Res Function(MarriageIntention) then,
  ) = _$MarriageIntentionCopyWithImpl<$Res, MarriageIntention>;
  @useResult
  $Res call({String id, String title, String description});
}

/// @nodoc
class _$MarriageIntentionCopyWithImpl<$Res, $Val extends MarriageIntention>
    implements $MarriageIntentionCopyWith<$Res> {
  _$MarriageIntentionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarriageIntention
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarriageIntentionImplCopyWith<$Res>
    implements $MarriageIntentionCopyWith<$Res> {
  factory _$$MarriageIntentionImplCopyWith(
    _$MarriageIntentionImpl value,
    $Res Function(_$MarriageIntentionImpl) then,
  ) = __$$MarriageIntentionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String description});
}

/// @nodoc
class __$$MarriageIntentionImplCopyWithImpl<$Res>
    extends _$MarriageIntentionCopyWithImpl<$Res, _$MarriageIntentionImpl>
    implements _$$MarriageIntentionImplCopyWith<$Res> {
  __$$MarriageIntentionImplCopyWithImpl(
    _$MarriageIntentionImpl _value,
    $Res Function(_$MarriageIntentionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MarriageIntention
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(
      _$MarriageIntentionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarriageIntentionImpl implements _MarriageIntention {
  const _$MarriageIntentionImpl({
    required this.id,
    required this.title,
    required this.description,
  });

  factory _$MarriageIntentionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarriageIntentionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;

  @override
  String toString() {
    return 'MarriageIntention(id: $id, title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarriageIntentionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description);

  /// Create a copy of MarriageIntention
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarriageIntentionImplCopyWith<_$MarriageIntentionImpl> get copyWith =>
      __$$MarriageIntentionImplCopyWithImpl<_$MarriageIntentionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MarriageIntentionImplToJson(this);
  }
}

abstract class _MarriageIntention implements MarriageIntention {
  const factory _MarriageIntention({
    required final String id,
    required final String title,
    required final String description,
  }) = _$MarriageIntentionImpl;

  factory _MarriageIntention.fromJson(Map<String, dynamic> json) =
      _$MarriageIntentionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;

  /// Create a copy of MarriageIntention
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarriageIntentionImplCopyWith<_$MarriageIntentionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FamilyValue _$FamilyValueFromJson(Map<String, dynamic> json) {
  return _FamilyValue.fromJson(json);
}

/// @nodoc
mixin _$FamilyValue {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this FamilyValue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FamilyValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyValueCopyWith<FamilyValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyValueCopyWith<$Res> {
  factory $FamilyValueCopyWith(
    FamilyValue value,
    $Res Function(FamilyValue) then,
  ) = _$FamilyValueCopyWithImpl<$Res, FamilyValue>;
  @useResult
  $Res call({String id, String title, String description});
}

/// @nodoc
class _$FamilyValueCopyWithImpl<$Res, $Val extends FamilyValue>
    implements $FamilyValueCopyWith<$Res> {
  _$FamilyValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilyValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FamilyValueImplCopyWith<$Res>
    implements $FamilyValueCopyWith<$Res> {
  factory _$$FamilyValueImplCopyWith(
    _$FamilyValueImpl value,
    $Res Function(_$FamilyValueImpl) then,
  ) = __$$FamilyValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String description});
}

/// @nodoc
class __$$FamilyValueImplCopyWithImpl<$Res>
    extends _$FamilyValueCopyWithImpl<$Res, _$FamilyValueImpl>
    implements _$$FamilyValueImplCopyWith<$Res> {
  __$$FamilyValueImplCopyWithImpl(
    _$FamilyValueImpl _value,
    $Res Function(_$FamilyValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilyValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(
      _$FamilyValueImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilyValueImpl implements _FamilyValue {
  const _$FamilyValueImpl({
    required this.id,
    required this.title,
    required this.description,
  });

  factory _$FamilyValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyValueImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;

  @override
  String toString() {
    return 'FamilyValue(id: $id, title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyValueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description);

  /// Create a copy of FamilyValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyValueImplCopyWith<_$FamilyValueImpl> get copyWith =>
      __$$FamilyValueImplCopyWithImpl<_$FamilyValueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyValueImplToJson(this);
  }
}

abstract class _FamilyValue implements FamilyValue {
  const factory _FamilyValue({
    required final String id,
    required final String title,
    required final String description,
  }) = _$FamilyValueImpl;

  factory _FamilyValue.fromJson(Map<String, dynamic> json) =
      _$FamilyValueImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;

  /// Create a copy of FamilyValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyValueImplCopyWith<_$FamilyValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReligiousPreference _$ReligiousPreferenceFromJson(Map<String, dynamic> json) {
  return _ReligiousPreference.fromJson(json);
}

/// @nodoc
mixin _$ReligiousPreference {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this ReligiousPreference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReligiousPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReligiousPreferenceCopyWith<ReligiousPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReligiousPreferenceCopyWith<$Res> {
  factory $ReligiousPreferenceCopyWith(
    ReligiousPreference value,
    $Res Function(ReligiousPreference) then,
  ) = _$ReligiousPreferenceCopyWithImpl<$Res, ReligiousPreference>;
  @useResult
  $Res call({String id, String title, String description});
}

/// @nodoc
class _$ReligiousPreferenceCopyWithImpl<$Res, $Val extends ReligiousPreference>
    implements $ReligiousPreferenceCopyWith<$Res> {
  _$ReligiousPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReligiousPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReligiousPreferenceImplCopyWith<$Res>
    implements $ReligiousPreferenceCopyWith<$Res> {
  factory _$$ReligiousPreferenceImplCopyWith(
    _$ReligiousPreferenceImpl value,
    $Res Function(_$ReligiousPreferenceImpl) then,
  ) = __$$ReligiousPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String description});
}

/// @nodoc
class __$$ReligiousPreferenceImplCopyWithImpl<$Res>
    extends _$ReligiousPreferenceCopyWithImpl<$Res, _$ReligiousPreferenceImpl>
    implements _$$ReligiousPreferenceImplCopyWith<$Res> {
  __$$ReligiousPreferenceImplCopyWithImpl(
    _$ReligiousPreferenceImpl _value,
    $Res Function(_$ReligiousPreferenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReligiousPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(
      _$ReligiousPreferenceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReligiousPreferenceImpl implements _ReligiousPreference {
  const _$ReligiousPreferenceImpl({
    required this.id,
    required this.title,
    required this.description,
  });

  factory _$ReligiousPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReligiousPreferenceImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;

  @override
  String toString() {
    return 'ReligiousPreference(id: $id, title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReligiousPreferenceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description);

  /// Create a copy of ReligiousPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReligiousPreferenceImplCopyWith<_$ReligiousPreferenceImpl> get copyWith =>
      __$$ReligiousPreferenceImplCopyWithImpl<_$ReligiousPreferenceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReligiousPreferenceImplToJson(this);
  }
}

abstract class _ReligiousPreference implements ReligiousPreference {
  const factory _ReligiousPreference({
    required final String id,
    required final String title,
    required final String description,
  }) = _$ReligiousPreferenceImpl;

  factory _ReligiousPreference.fromJson(Map<String, dynamic> json) =
      _$ReligiousPreferenceImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;

  /// Create a copy of ReligiousPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReligiousPreferenceImplCopyWith<_$ReligiousPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PartnerPreferences _$PartnerPreferencesFromJson(Map<String, dynamic> json) {
  return _PartnerPreferences.fromJson(json);
}

/// @nodoc
mixin _$PartnerPreferences {
  int get minAge => throw _privateConstructorUsedError;
  int get maxAge => throw _privateConstructorUsedError;
  List<String> get preferredEducation => throw _privateConstructorUsedError;
  List<String> get preferredLocations => throw _privateConstructorUsedError;
  List<String> get preferredReligions => throw _privateConstructorUsedError;
  List<String> get preferredLanguages => throw _privateConstructorUsedError;
  String? get minHeight => throw _privateConstructorUsedError;
  String? get maxHeight => throw _privateConstructorUsedError;
  bool get mustBeReligious => throw _privateConstructorUsedError;
  bool get mustWantChildren => throw _privateConstructorUsedError;
  bool get mustBeNeverMarried => throw _privateConstructorUsedError;

  /// Serializes this PartnerPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PartnerPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartnerPreferencesCopyWith<PartnerPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerPreferencesCopyWith<$Res> {
  factory $PartnerPreferencesCopyWith(
    PartnerPreferences value,
    $Res Function(PartnerPreferences) then,
  ) = _$PartnerPreferencesCopyWithImpl<$Res, PartnerPreferences>;
  @useResult
  $Res call({
    int minAge,
    int maxAge,
    List<String> preferredEducation,
    List<String> preferredLocations,
    List<String> preferredReligions,
    List<String> preferredLanguages,
    String? minHeight,
    String? maxHeight,
    bool mustBeReligious,
    bool mustWantChildren,
    bool mustBeNeverMarried,
  });
}

/// @nodoc
class _$PartnerPreferencesCopyWithImpl<$Res, $Val extends PartnerPreferences>
    implements $PartnerPreferencesCopyWith<$Res> {
  _$PartnerPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartnerPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minAge = null,
    Object? maxAge = null,
    Object? preferredEducation = null,
    Object? preferredLocations = null,
    Object? preferredReligions = null,
    Object? preferredLanguages = null,
    Object? minHeight = freezed,
    Object? maxHeight = freezed,
    Object? mustBeReligious = null,
    Object? mustWantChildren = null,
    Object? mustBeNeverMarried = null,
  }) {
    return _then(
      _value.copyWith(
            minAge: null == minAge
                ? _value.minAge
                : minAge // ignore: cast_nullable_to_non_nullable
                      as int,
            maxAge: null == maxAge
                ? _value.maxAge
                : maxAge // ignore: cast_nullable_to_non_nullable
                      as int,
            preferredEducation: null == preferredEducation
                ? _value.preferredEducation
                : preferredEducation // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            preferredLocations: null == preferredLocations
                ? _value.preferredLocations
                : preferredLocations // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            preferredReligions: null == preferredReligions
                ? _value.preferredReligions
                : preferredReligions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            preferredLanguages: null == preferredLanguages
                ? _value.preferredLanguages
                : preferredLanguages // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            minHeight: freezed == minHeight
                ? _value.minHeight
                : minHeight // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxHeight: freezed == maxHeight
                ? _value.maxHeight
                : maxHeight // ignore: cast_nullable_to_non_nullable
                      as String?,
            mustBeReligious: null == mustBeReligious
                ? _value.mustBeReligious
                : mustBeReligious // ignore: cast_nullable_to_non_nullable
                      as bool,
            mustWantChildren: null == mustWantChildren
                ? _value.mustWantChildren
                : mustWantChildren // ignore: cast_nullable_to_non_nullable
                      as bool,
            mustBeNeverMarried: null == mustBeNeverMarried
                ? _value.mustBeNeverMarried
                : mustBeNeverMarried // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PartnerPreferencesImplCopyWith<$Res>
    implements $PartnerPreferencesCopyWith<$Res> {
  factory _$$PartnerPreferencesImplCopyWith(
    _$PartnerPreferencesImpl value,
    $Res Function(_$PartnerPreferencesImpl) then,
  ) = __$$PartnerPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int minAge,
    int maxAge,
    List<String> preferredEducation,
    List<String> preferredLocations,
    List<String> preferredReligions,
    List<String> preferredLanguages,
    String? minHeight,
    String? maxHeight,
    bool mustBeReligious,
    bool mustWantChildren,
    bool mustBeNeverMarried,
  });
}

/// @nodoc
class __$$PartnerPreferencesImplCopyWithImpl<$Res>
    extends _$PartnerPreferencesCopyWithImpl<$Res, _$PartnerPreferencesImpl>
    implements _$$PartnerPreferencesImplCopyWith<$Res> {
  __$$PartnerPreferencesImplCopyWithImpl(
    _$PartnerPreferencesImpl _value,
    $Res Function(_$PartnerPreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PartnerPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minAge = null,
    Object? maxAge = null,
    Object? preferredEducation = null,
    Object? preferredLocations = null,
    Object? preferredReligions = null,
    Object? preferredLanguages = null,
    Object? minHeight = freezed,
    Object? maxHeight = freezed,
    Object? mustBeReligious = null,
    Object? mustWantChildren = null,
    Object? mustBeNeverMarried = null,
  }) {
    return _then(
      _$PartnerPreferencesImpl(
        minAge: null == minAge
            ? _value.minAge
            : minAge // ignore: cast_nullable_to_non_nullable
                  as int,
        maxAge: null == maxAge
            ? _value.maxAge
            : maxAge // ignore: cast_nullable_to_non_nullable
                  as int,
        preferredEducation: null == preferredEducation
            ? _value._preferredEducation
            : preferredEducation // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        preferredLocations: null == preferredLocations
            ? _value._preferredLocations
            : preferredLocations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        preferredReligions: null == preferredReligions
            ? _value._preferredReligions
            : preferredReligions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        preferredLanguages: null == preferredLanguages
            ? _value._preferredLanguages
            : preferredLanguages // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        minHeight: freezed == minHeight
            ? _value.minHeight
            : minHeight // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxHeight: freezed == maxHeight
            ? _value.maxHeight
            : maxHeight // ignore: cast_nullable_to_non_nullable
                  as String?,
        mustBeReligious: null == mustBeReligious
            ? _value.mustBeReligious
            : mustBeReligious // ignore: cast_nullable_to_non_nullable
                  as bool,
        mustWantChildren: null == mustWantChildren
            ? _value.mustWantChildren
            : mustWantChildren // ignore: cast_nullable_to_non_nullable
                  as bool,
        mustBeNeverMarried: null == mustBeNeverMarried
            ? _value.mustBeNeverMarried
            : mustBeNeverMarried // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PartnerPreferencesImpl implements _PartnerPreferences {
  const _$PartnerPreferencesImpl({
    this.minAge = 18,
    this.maxAge = 100,
    final List<String> preferredEducation = const [],
    final List<String> preferredLocations = const [],
    final List<String> preferredReligions = const [],
    final List<String> preferredLanguages = const [],
    this.minHeight,
    this.maxHeight,
    this.mustBeReligious = false,
    this.mustWantChildren = false,
    this.mustBeNeverMarried = false,
  }) : _preferredEducation = preferredEducation,
       _preferredLocations = preferredLocations,
       _preferredReligions = preferredReligions,
       _preferredLanguages = preferredLanguages;

  factory _$PartnerPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartnerPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final int minAge;
  @override
  @JsonKey()
  final int maxAge;
  final List<String> _preferredEducation;
  @override
  @JsonKey()
  List<String> get preferredEducation {
    if (_preferredEducation is EqualUnmodifiableListView)
      return _preferredEducation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredEducation);
  }

  final List<String> _preferredLocations;
  @override
  @JsonKey()
  List<String> get preferredLocations {
    if (_preferredLocations is EqualUnmodifiableListView)
      return _preferredLocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredLocations);
  }

  final List<String> _preferredReligions;
  @override
  @JsonKey()
  List<String> get preferredReligions {
    if (_preferredReligions is EqualUnmodifiableListView)
      return _preferredReligions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredReligions);
  }

  final List<String> _preferredLanguages;
  @override
  @JsonKey()
  List<String> get preferredLanguages {
    if (_preferredLanguages is EqualUnmodifiableListView)
      return _preferredLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredLanguages);
  }

  @override
  final String? minHeight;
  @override
  final String? maxHeight;
  @override
  @JsonKey()
  final bool mustBeReligious;
  @override
  @JsonKey()
  final bool mustWantChildren;
  @override
  @JsonKey()
  final bool mustBeNeverMarried;

  @override
  String toString() {
    return 'PartnerPreferences(minAge: $minAge, maxAge: $maxAge, preferredEducation: $preferredEducation, preferredLocations: $preferredLocations, preferredReligions: $preferredReligions, preferredLanguages: $preferredLanguages, minHeight: $minHeight, maxHeight: $maxHeight, mustBeReligious: $mustBeReligious, mustWantChildren: $mustWantChildren, mustBeNeverMarried: $mustBeNeverMarried)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerPreferencesImpl &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            const DeepCollectionEquality().equals(
              other._preferredEducation,
              _preferredEducation,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredLocations,
              _preferredLocations,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredReligions,
              _preferredReligions,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredLanguages,
              _preferredLanguages,
            ) &&
            (identical(other.minHeight, minHeight) ||
                other.minHeight == minHeight) &&
            (identical(other.maxHeight, maxHeight) ||
                other.maxHeight == maxHeight) &&
            (identical(other.mustBeReligious, mustBeReligious) ||
                other.mustBeReligious == mustBeReligious) &&
            (identical(other.mustWantChildren, mustWantChildren) ||
                other.mustWantChildren == mustWantChildren) &&
            (identical(other.mustBeNeverMarried, mustBeNeverMarried) ||
                other.mustBeNeverMarried == mustBeNeverMarried));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    minAge,
    maxAge,
    const DeepCollectionEquality().hash(_preferredEducation),
    const DeepCollectionEquality().hash(_preferredLocations),
    const DeepCollectionEquality().hash(_preferredReligions),
    const DeepCollectionEquality().hash(_preferredLanguages),
    minHeight,
    maxHeight,
    mustBeReligious,
    mustWantChildren,
    mustBeNeverMarried,
  );

  /// Create a copy of PartnerPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerPreferencesImplCopyWith<_$PartnerPreferencesImpl> get copyWith =>
      __$$PartnerPreferencesImplCopyWithImpl<_$PartnerPreferencesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PartnerPreferencesImplToJson(this);
  }
}

abstract class _PartnerPreferences implements PartnerPreferences {
  const factory _PartnerPreferences({
    final int minAge,
    final int maxAge,
    final List<String> preferredEducation,
    final List<String> preferredLocations,
    final List<String> preferredReligions,
    final List<String> preferredLanguages,
    final String? minHeight,
    final String? maxHeight,
    final bool mustBeReligious,
    final bool mustWantChildren,
    final bool mustBeNeverMarried,
  }) = _$PartnerPreferencesImpl;

  factory _PartnerPreferences.fromJson(Map<String, dynamic> json) =
      _$PartnerPreferencesImpl.fromJson;

  @override
  int get minAge;
  @override
  int get maxAge;
  @override
  List<String> get preferredEducation;
  @override
  List<String> get preferredLocations;
  @override
  List<String> get preferredReligions;
  @override
  List<String> get preferredLanguages;
  @override
  String? get minHeight;
  @override
  String? get maxHeight;
  @override
  bool get mustBeReligious;
  @override
  bool get mustWantChildren;
  @override
  bool get mustBeNeverMarried;

  /// Create a copy of PartnerPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartnerPreferencesImplCopyWith<_$PartnerPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatrimonyOnboardingData _$MatrimonyOnboardingDataFromJson(
  Map<String, dynamic> json,
) {
  return _MatrimonyOnboardingData.fromJson(json);
}

/// @nodoc
mixin _$MatrimonyOnboardingData {
  String? get marriageIntentionId => throw _privateConstructorUsedError;
  List<String> get familyValueIds => throw _privateConstructorUsedError;
  String? get religiousPreferenceId => throw _privateConstructorUsedError;
  PartnerPreferences? get partnerPreferences =>
      throw _privateConstructorUsedError;
  bool get requiresFamilyApproval => throw _privateConstructorUsedError;
  String? get familyApprovalDetails => throw _privateConstructorUsedError;

  /// Serializes this MatrimonyOnboardingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatrimonyOnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatrimonyOnboardingDataCopyWith<MatrimonyOnboardingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatrimonyOnboardingDataCopyWith<$Res> {
  factory $MatrimonyOnboardingDataCopyWith(
    MatrimonyOnboardingData value,
    $Res Function(MatrimonyOnboardingData) then,
  ) = _$MatrimonyOnboardingDataCopyWithImpl<$Res, MatrimonyOnboardingData>;
  @useResult
  $Res call({
    String? marriageIntentionId,
    List<String> familyValueIds,
    String? religiousPreferenceId,
    PartnerPreferences? partnerPreferences,
    bool requiresFamilyApproval,
    String? familyApprovalDetails,
  });

  $PartnerPreferencesCopyWith<$Res>? get partnerPreferences;
}

/// @nodoc
class _$MatrimonyOnboardingDataCopyWithImpl<
  $Res,
  $Val extends MatrimonyOnboardingData
>
    implements $MatrimonyOnboardingDataCopyWith<$Res> {
  _$MatrimonyOnboardingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatrimonyOnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? marriageIntentionId = freezed,
    Object? familyValueIds = null,
    Object? religiousPreferenceId = freezed,
    Object? partnerPreferences = freezed,
    Object? requiresFamilyApproval = null,
    Object? familyApprovalDetails = freezed,
  }) {
    return _then(
      _value.copyWith(
            marriageIntentionId: freezed == marriageIntentionId
                ? _value.marriageIntentionId
                : marriageIntentionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            familyValueIds: null == familyValueIds
                ? _value.familyValueIds
                : familyValueIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            religiousPreferenceId: freezed == religiousPreferenceId
                ? _value.religiousPreferenceId
                : religiousPreferenceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            partnerPreferences: freezed == partnerPreferences
                ? _value.partnerPreferences
                : partnerPreferences // ignore: cast_nullable_to_non_nullable
                      as PartnerPreferences?,
            requiresFamilyApproval: null == requiresFamilyApproval
                ? _value.requiresFamilyApproval
                : requiresFamilyApproval // ignore: cast_nullable_to_non_nullable
                      as bool,
            familyApprovalDetails: freezed == familyApprovalDetails
                ? _value.familyApprovalDetails
                : familyApprovalDetails // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of MatrimonyOnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PartnerPreferencesCopyWith<$Res>? get partnerPreferences {
    if (_value.partnerPreferences == null) {
      return null;
    }

    return $PartnerPreferencesCopyWith<$Res>(_value.partnerPreferences!, (
      value,
    ) {
      return _then(_value.copyWith(partnerPreferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatrimonyOnboardingDataImplCopyWith<$Res>
    implements $MatrimonyOnboardingDataCopyWith<$Res> {
  factory _$$MatrimonyOnboardingDataImplCopyWith(
    _$MatrimonyOnboardingDataImpl value,
    $Res Function(_$MatrimonyOnboardingDataImpl) then,
  ) = __$$MatrimonyOnboardingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? marriageIntentionId,
    List<String> familyValueIds,
    String? religiousPreferenceId,
    PartnerPreferences? partnerPreferences,
    bool requiresFamilyApproval,
    String? familyApprovalDetails,
  });

  @override
  $PartnerPreferencesCopyWith<$Res>? get partnerPreferences;
}

/// @nodoc
class __$$MatrimonyOnboardingDataImplCopyWithImpl<$Res>
    extends
        _$MatrimonyOnboardingDataCopyWithImpl<
          $Res,
          _$MatrimonyOnboardingDataImpl
        >
    implements _$$MatrimonyOnboardingDataImplCopyWith<$Res> {
  __$$MatrimonyOnboardingDataImplCopyWithImpl(
    _$MatrimonyOnboardingDataImpl _value,
    $Res Function(_$MatrimonyOnboardingDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatrimonyOnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? marriageIntentionId = freezed,
    Object? familyValueIds = null,
    Object? religiousPreferenceId = freezed,
    Object? partnerPreferences = freezed,
    Object? requiresFamilyApproval = null,
    Object? familyApprovalDetails = freezed,
  }) {
    return _then(
      _$MatrimonyOnboardingDataImpl(
        marriageIntentionId: freezed == marriageIntentionId
            ? _value.marriageIntentionId
            : marriageIntentionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        familyValueIds: null == familyValueIds
            ? _value._familyValueIds
            : familyValueIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        religiousPreferenceId: freezed == religiousPreferenceId
            ? _value.religiousPreferenceId
            : religiousPreferenceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        partnerPreferences: freezed == partnerPreferences
            ? _value.partnerPreferences
            : partnerPreferences // ignore: cast_nullable_to_non_nullable
                  as PartnerPreferences?,
        requiresFamilyApproval: null == requiresFamilyApproval
            ? _value.requiresFamilyApproval
            : requiresFamilyApproval // ignore: cast_nullable_to_non_nullable
                  as bool,
        familyApprovalDetails: freezed == familyApprovalDetails
            ? _value.familyApprovalDetails
            : familyApprovalDetails // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatrimonyOnboardingDataImpl implements _MatrimonyOnboardingData {
  const _$MatrimonyOnboardingDataImpl({
    this.marriageIntentionId,
    final List<String> familyValueIds = const [],
    this.religiousPreferenceId,
    this.partnerPreferences,
    this.requiresFamilyApproval = false,
    this.familyApprovalDetails,
  }) : _familyValueIds = familyValueIds;

  factory _$MatrimonyOnboardingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatrimonyOnboardingDataImplFromJson(json);

  @override
  final String? marriageIntentionId;
  final List<String> _familyValueIds;
  @override
  @JsonKey()
  List<String> get familyValueIds {
    if (_familyValueIds is EqualUnmodifiableListView) return _familyValueIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_familyValueIds);
  }

  @override
  final String? religiousPreferenceId;
  @override
  final PartnerPreferences? partnerPreferences;
  @override
  @JsonKey()
  final bool requiresFamilyApproval;
  @override
  final String? familyApprovalDetails;

  @override
  String toString() {
    return 'MatrimonyOnboardingData(marriageIntentionId: $marriageIntentionId, familyValueIds: $familyValueIds, religiousPreferenceId: $religiousPreferenceId, partnerPreferences: $partnerPreferences, requiresFamilyApproval: $requiresFamilyApproval, familyApprovalDetails: $familyApprovalDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatrimonyOnboardingDataImpl &&
            (identical(other.marriageIntentionId, marriageIntentionId) ||
                other.marriageIntentionId == marriageIntentionId) &&
            const DeepCollectionEquality().equals(
              other._familyValueIds,
              _familyValueIds,
            ) &&
            (identical(other.religiousPreferenceId, religiousPreferenceId) ||
                other.religiousPreferenceId == religiousPreferenceId) &&
            (identical(other.partnerPreferences, partnerPreferences) ||
                other.partnerPreferences == partnerPreferences) &&
            (identical(other.requiresFamilyApproval, requiresFamilyApproval) ||
                other.requiresFamilyApproval == requiresFamilyApproval) &&
            (identical(other.familyApprovalDetails, familyApprovalDetails) ||
                other.familyApprovalDetails == familyApprovalDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    marriageIntentionId,
    const DeepCollectionEquality().hash(_familyValueIds),
    religiousPreferenceId,
    partnerPreferences,
    requiresFamilyApproval,
    familyApprovalDetails,
  );

  /// Create a copy of MatrimonyOnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatrimonyOnboardingDataImplCopyWith<_$MatrimonyOnboardingDataImpl>
  get copyWith =>
      __$$MatrimonyOnboardingDataImplCopyWithImpl<
        _$MatrimonyOnboardingDataImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatrimonyOnboardingDataImplToJson(this);
  }
}

abstract class _MatrimonyOnboardingData implements MatrimonyOnboardingData {
  const factory _MatrimonyOnboardingData({
    final String? marriageIntentionId,
    final List<String> familyValueIds,
    final String? religiousPreferenceId,
    final PartnerPreferences? partnerPreferences,
    final bool requiresFamilyApproval,
    final String? familyApprovalDetails,
  }) = _$MatrimonyOnboardingDataImpl;

  factory _MatrimonyOnboardingData.fromJson(Map<String, dynamic> json) =
      _$MatrimonyOnboardingDataImpl.fromJson;

  @override
  String? get marriageIntentionId;
  @override
  List<String> get familyValueIds;
  @override
  String? get religiousPreferenceId;
  @override
  PartnerPreferences? get partnerPreferences;
  @override
  bool get requiresFamilyApproval;
  @override
  String? get familyApprovalDetails;

  /// Create a copy of MatrimonyOnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatrimonyOnboardingDataImplCopyWith<_$MatrimonyOnboardingDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MatrimonyOnboardingStep _$MatrimonyOnboardingStepFromJson(
  Map<String, dynamic> json,
) {
  return _MatrimonyOnboardingStep.fromJson(json);
}

/// @nodoc
mixin _$MatrimonyOnboardingStep {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this MatrimonyOnboardingStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatrimonyOnboardingStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatrimonyOnboardingStepCopyWith<MatrimonyOnboardingStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatrimonyOnboardingStepCopyWith<$Res> {
  factory $MatrimonyOnboardingStepCopyWith(
    MatrimonyOnboardingStep value,
    $Res Function(MatrimonyOnboardingStep) then,
  ) = _$MatrimonyOnboardingStepCopyWithImpl<$Res, MatrimonyOnboardingStep>;
  @useResult
  $Res call({
    String id,
    String title,
    String subtitle,
    String description,
    int index,
    bool isCompleted,
  });
}

/// @nodoc
class _$MatrimonyOnboardingStepCopyWithImpl<
  $Res,
  $Val extends MatrimonyOnboardingStep
>
    implements $MatrimonyOnboardingStepCopyWith<$Res> {
  _$MatrimonyOnboardingStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatrimonyOnboardingStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? description = null,
    Object? index = null,
    Object? isCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            subtitle: null == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            index: null == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatrimonyOnboardingStepImplCopyWith<$Res>
    implements $MatrimonyOnboardingStepCopyWith<$Res> {
  factory _$$MatrimonyOnboardingStepImplCopyWith(
    _$MatrimonyOnboardingStepImpl value,
    $Res Function(_$MatrimonyOnboardingStepImpl) then,
  ) = __$$MatrimonyOnboardingStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String subtitle,
    String description,
    int index,
    bool isCompleted,
  });
}

/// @nodoc
class __$$MatrimonyOnboardingStepImplCopyWithImpl<$Res>
    extends
        _$MatrimonyOnboardingStepCopyWithImpl<
          $Res,
          _$MatrimonyOnboardingStepImpl
        >
    implements _$$MatrimonyOnboardingStepImplCopyWith<$Res> {
  __$$MatrimonyOnboardingStepImplCopyWithImpl(
    _$MatrimonyOnboardingStepImpl _value,
    $Res Function(_$MatrimonyOnboardingStepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatrimonyOnboardingStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? description = null,
    Object? index = null,
    Object? isCompleted = null,
  }) {
    return _then(
      _$MatrimonyOnboardingStepImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        subtitle: null == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        index: null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatrimonyOnboardingStepImpl implements _MatrimonyOnboardingStep {
  const _$MatrimonyOnboardingStepImpl({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.index,
    required this.isCompleted,
  });

  factory _$MatrimonyOnboardingStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatrimonyOnboardingStepImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final String description;
  @override
  final int index;
  @override
  final bool isCompleted;

  @override
  String toString() {
    return 'MatrimonyOnboardingStep(id: $id, title: $title, subtitle: $subtitle, description: $description, index: $index, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatrimonyOnboardingStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    subtitle,
    description,
    index,
    isCompleted,
  );

  /// Create a copy of MatrimonyOnboardingStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatrimonyOnboardingStepImplCopyWith<_$MatrimonyOnboardingStepImpl>
  get copyWith =>
      __$$MatrimonyOnboardingStepImplCopyWithImpl<
        _$MatrimonyOnboardingStepImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatrimonyOnboardingStepImplToJson(this);
  }
}

abstract class _MatrimonyOnboardingStep implements MatrimonyOnboardingStep {
  const factory _MatrimonyOnboardingStep({
    required final String id,
    required final String title,
    required final String subtitle,
    required final String description,
    required final int index,
    required final bool isCompleted,
  }) = _$MatrimonyOnboardingStepImpl;

  factory _MatrimonyOnboardingStep.fromJson(Map<String, dynamic> json) =
      _$MatrimonyOnboardingStepImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get subtitle;
  @override
  String get description;
  @override
  int get index;
  @override
  bool get isCompleted;

  /// Create a copy of MatrimonyOnboardingStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatrimonyOnboardingStepImplCopyWith<_$MatrimonyOnboardingStepImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MatrimonyOnboardingState _$MatrimonyOnboardingStateFromJson(
  Map<String, dynamic> json,
) {
  return _MatrimonyOnboardingState.fromJson(json);
}

/// @nodoc
mixin _$MatrimonyOnboardingState {
  List<MatrimonyOnboardingStep> get steps => throw _privateConstructorUsedError;
  int get currentStepIndex => throw _privateConstructorUsedError;
  MatrimonyOnboardingData? get data => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this MatrimonyOnboardingState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatrimonyOnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatrimonyOnboardingStateCopyWith<MatrimonyOnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatrimonyOnboardingStateCopyWith<$Res> {
  factory $MatrimonyOnboardingStateCopyWith(
    MatrimonyOnboardingState value,
    $Res Function(MatrimonyOnboardingState) then,
  ) = _$MatrimonyOnboardingStateCopyWithImpl<$Res, MatrimonyOnboardingState>;
  @useResult
  $Res call({
    List<MatrimonyOnboardingStep> steps,
    int currentStepIndex,
    MatrimonyOnboardingData? data,
    bool isLoading,
    String? error,
    bool isCompleted,
  });

  $MatrimonyOnboardingDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$MatrimonyOnboardingStateCopyWithImpl<
  $Res,
  $Val extends MatrimonyOnboardingState
>
    implements $MatrimonyOnboardingStateCopyWith<$Res> {
  _$MatrimonyOnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatrimonyOnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? steps = null,
    Object? currentStepIndex = null,
    Object? data = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<MatrimonyOnboardingStep>,
            currentStepIndex: null == currentStepIndex
                ? _value.currentStepIndex
                : currentStepIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as MatrimonyOnboardingData?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of MatrimonyOnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatrimonyOnboardingDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $MatrimonyOnboardingDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatrimonyOnboardingStateImplCopyWith<$Res>
    implements $MatrimonyOnboardingStateCopyWith<$Res> {
  factory _$$MatrimonyOnboardingStateImplCopyWith(
    _$MatrimonyOnboardingStateImpl value,
    $Res Function(_$MatrimonyOnboardingStateImpl) then,
  ) = __$$MatrimonyOnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MatrimonyOnboardingStep> steps,
    int currentStepIndex,
    MatrimonyOnboardingData? data,
    bool isLoading,
    String? error,
    bool isCompleted,
  });

  @override
  $MatrimonyOnboardingDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$MatrimonyOnboardingStateImplCopyWithImpl<$Res>
    extends
        _$MatrimonyOnboardingStateCopyWithImpl<
          $Res,
          _$MatrimonyOnboardingStateImpl
        >
    implements _$$MatrimonyOnboardingStateImplCopyWith<$Res> {
  __$$MatrimonyOnboardingStateImplCopyWithImpl(
    _$MatrimonyOnboardingStateImpl _value,
    $Res Function(_$MatrimonyOnboardingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatrimonyOnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? steps = null,
    Object? currentStepIndex = null,
    Object? data = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _$MatrimonyOnboardingStateImpl(
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<MatrimonyOnboardingStep>,
        currentStepIndex: null == currentStepIndex
            ? _value.currentStepIndex
            : currentStepIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as MatrimonyOnboardingData?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatrimonyOnboardingStateImpl implements _MatrimonyOnboardingState {
  const _$MatrimonyOnboardingStateImpl({
    final List<MatrimonyOnboardingStep> steps = const [],
    this.currentStepIndex = 0,
    this.data,
    this.isLoading = false,
    this.error,
    this.isCompleted = false,
  }) : _steps = steps;

  factory _$MatrimonyOnboardingStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatrimonyOnboardingStateImplFromJson(json);

  final List<MatrimonyOnboardingStep> _steps;
  @override
  @JsonKey()
  List<MatrimonyOnboardingStep> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  @JsonKey()
  final int currentStepIndex;
  @override
  final MatrimonyOnboardingData? data;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'MatrimonyOnboardingState(steps: $steps, currentStepIndex: $currentStepIndex, data: $data, isLoading: $isLoading, error: $error, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatrimonyOnboardingStateImpl &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.currentStepIndex, currentStepIndex) ||
                other.currentStepIndex == currentStepIndex) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_steps),
    currentStepIndex,
    data,
    isLoading,
    error,
    isCompleted,
  );

  /// Create a copy of MatrimonyOnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatrimonyOnboardingStateImplCopyWith<_$MatrimonyOnboardingStateImpl>
  get copyWith =>
      __$$MatrimonyOnboardingStateImplCopyWithImpl<
        _$MatrimonyOnboardingStateImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatrimonyOnboardingStateImplToJson(this);
  }
}

abstract class _MatrimonyOnboardingState implements MatrimonyOnboardingState {
  const factory _MatrimonyOnboardingState({
    final List<MatrimonyOnboardingStep> steps,
    final int currentStepIndex,
    final MatrimonyOnboardingData? data,
    final bool isLoading,
    final String? error,
    final bool isCompleted,
  }) = _$MatrimonyOnboardingStateImpl;

  factory _MatrimonyOnboardingState.fromJson(Map<String, dynamic> json) =
      _$MatrimonyOnboardingStateImpl.fromJson;

  @override
  List<MatrimonyOnboardingStep> get steps;
  @override
  int get currentStepIndex;
  @override
  MatrimonyOnboardingData? get data;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  bool get isCompleted;

  /// Create a copy of MatrimonyOnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatrimonyOnboardingStateImplCopyWith<_$MatrimonyOnboardingStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

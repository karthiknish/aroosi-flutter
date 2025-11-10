part of 'package:aroosi_flutter/features/profiles/models.dart';

class SearchFilters {
  const SearchFilters({
    this.query,
    this.minAge,
    this.maxAge,
    this.city,
    this.country,
    this.sort,
    this.cursor,
    this.pageSize,
    this.preferredGender,
    this.religion,
    this.religiousPractice,
    this.motherTongue,
    this.languages,
    this.familyValues,
    this.marriageViews,
    this.ethnicity,
    this.minReligionImportance,
    this.maxReligionImportance,
    this.minCultureImportance,
    this.maxCultureImportance,
    this.education,
    this.occupation,
    this.annualIncome,
    this.minIncome,
    this.maxIncome,
    this.height,
    this.minHeight,
    this.maxHeight,
    this.physicalStatus,
    this.maritalStatus,
    this.diet,
    this.smoking,
    this.drinking,
    this.marriageIntention,
    this.requiresFamilyApproval,
    this.mustBeReligious,
    this.mustWantChildren,
    this.mustBeNeverMarried,
    this.locationRadius,
    this.latitude,
    this.longitude,
  });

  static const Object _unset = Object();

  final String? query;
  final int? minAge;
  final int? maxAge;
  final String? city;
  final String? country;
  final String? sort; // e.g., 'recent', 'distance', 'newest'
  final String? cursor;
  final int? pageSize;
  final String? preferredGender;
  final String? religion;
  final String? religiousPractice;
  final String? motherTongue;
  final List<String>? languages;
  final String? familyValues;
  final String? marriageViews;
  final String? ethnicity;
  final int? minReligionImportance;
  final int? maxReligionImportance;
  final int? minCultureImportance;
  final int? maxCultureImportance;
  final String? education;
  final String? occupation;
  final int? annualIncome;
  final int? minIncome;
  final int? maxIncome;
  final String? height;
  final String? minHeight;
  final String? maxHeight;
  final String? physicalStatus;
  final String? maritalStatus;
  final String? diet;
  final String? smoking;
  final String? drinking;
  final String? marriageIntention;
  final bool? requiresFamilyApproval;
  final bool? mustBeReligious;
  final bool? mustWantChildren;
  final bool? mustBeNeverMarried;
  final int? locationRadius;
  final double? latitude;
  final double? longitude;

  SearchFilters copyWith({
    Object? query = _unset,
    Object? minAge = _unset,
    Object? maxAge = _unset,
    Object? city = _unset,
    Object? country = _unset,
    Object? sort = _unset,
    Object? cursor = _unset,
    Object? pageSize = _unset,
    Object? preferredGender = _unset,
    Object? religion = _unset,
    Object? religiousPractice = _unset,
    Object? motherTongue = _unset,
    Object? languages = _unset,
    Object? familyValues = _unset,
    Object? marriageViews = _unset,
    Object? ethnicity = _unset,
    Object? minReligionImportance = _unset,
    Object? maxReligionImportance = _unset,
    Object? minCultureImportance = _unset,
    Object? maxCultureImportance = _unset,
    Object? education = _unset,
    Object? occupation = _unset,
    Object? annualIncome = _unset,
    Object? minIncome = _unset,
    Object? maxIncome = _unset,
    Object? height = _unset,
    Object? minHeight = _unset,
    Object? maxHeight = _unset,
    Object? physicalStatus = _unset,
    Object? maritalStatus = _unset,
    Object? diet = _unset,
    Object? smoking = _unset,
    Object? drinking = _unset,
    Object? marriageIntention = _unset,
    Object? requiresFamilyApproval = _unset,
    Object? mustBeReligious = _unset,
    Object? mustWantChildren = _unset,
    Object? mustBeNeverMarried = _unset,
    Object? locationRadius = _unset,
    Object? latitude = _unset,
    Object? longitude = _unset,
  }) => SearchFilters(
        query: query == _unset ? this.query : query as String?,
        minAge: minAge == _unset ? this.minAge : minAge as int?,
        maxAge: maxAge == _unset ? this.maxAge : maxAge as int?,
        city: city == _unset ? this.city : city as String?,
        country: country == _unset ? this.country : country as String?,
        sort: sort == _unset ? this.sort : sort as String?,
        cursor: cursor == _unset ? this.cursor : cursor as String?,
        pageSize: pageSize == _unset ? this.pageSize : pageSize as int?,
        preferredGender: preferredGender == _unset
            ? this.preferredGender
            : preferredGender as String?,
        religion: religion == _unset ? this.religion : religion as String?,
        religiousPractice: religiousPractice == _unset
            ? this.religiousPractice
            : religiousPractice as String?,
        motherTongue: motherTongue == _unset
            ? this.motherTongue
            : motherTongue as String?,
        languages: languages == _unset
            ? this.languages
            : languages as List<String>?,
        familyValues: familyValues == _unset
            ? this.familyValues
            : familyValues as String?,
        marriageViews: marriageViews == _unset
            ? this.marriageViews
            : marriageViews as String?,
        ethnicity:
            ethnicity == _unset ? this.ethnicity : ethnicity as String?,
        minReligionImportance: minReligionImportance == _unset
            ? this.minReligionImportance
            : minReligionImportance as int?,
        maxReligionImportance: maxReligionImportance == _unset
            ? this.maxReligionImportance
            : maxReligionImportance as int?,
        minCultureImportance: minCultureImportance == _unset
            ? this.minCultureImportance
            : minCultureImportance as int?,
        maxCultureImportance: maxCultureImportance == _unset
            ? this.maxCultureImportance
            : maxCultureImportance as int?,
        education: education == _unset ? this.education : education as String?,
        occupation: occupation == _unset
            ? this.occupation
            : occupation as String?,
        annualIncome: annualIncome == _unset
            ? this.annualIncome
            : annualIncome as int?,
        minIncome:
            minIncome == _unset ? this.minIncome : minIncome as int?,
        maxIncome:
            maxIncome == _unset ? this.maxIncome : maxIncome as int?,
        height: height == _unset ? this.height : height as String?,
        minHeight:
            minHeight == _unset ? this.minHeight : minHeight as String?,
        maxHeight:
            maxHeight == _unset ? this.maxHeight : maxHeight as String?,
        physicalStatus: physicalStatus == _unset
            ? this.physicalStatus
            : physicalStatus as String?,
        maritalStatus: maritalStatus == _unset
            ? this.maritalStatus
            : maritalStatus as String?,
        diet: diet == _unset ? this.diet : diet as String?,
        smoking: smoking == _unset ? this.smoking : smoking as String?,
        drinking: drinking == _unset ? this.drinking : drinking as String?,
        marriageIntention: marriageIntention == _unset
            ? this.marriageIntention
            : marriageIntention as String?,
        requiresFamilyApproval: requiresFamilyApproval == _unset
            ? this.requiresFamilyApproval
            : requiresFamilyApproval as bool?,
        mustBeReligious: mustBeReligious == _unset
            ? this.mustBeReligious
            : mustBeReligious as bool?,
        mustWantChildren: mustWantChildren == _unset
            ? this.mustWantChildren
            : mustWantChildren as bool?,
        mustBeNeverMarried: mustBeNeverMarried == _unset
            ? this.mustBeNeverMarried
            : mustBeNeverMarried as bool?,
        locationRadius: locationRadius == _unset
            ? this.locationRadius
            : locationRadius as int?,
        latitude:
            latitude == _unset ? this.latitude : latitude as double?,
        longitude:
            longitude == _unset ? this.longitude : longitude as double?,
      );

  bool get hasQuery => query?.trim().isNotEmpty ?? false;

  bool get hasFieldFilters =>
      minAge != null ||
      maxAge != null ||
      (city?.trim().isNotEmpty ?? false) ||
      (country?.trim().isNotEmpty ?? false) ||
      (sort?.trim().isNotEmpty ?? false) ||
      (preferredGender?.trim().isNotEmpty ?? false) ||
      (religion?.trim().isNotEmpty ?? false) ||
      (religiousPractice?.trim().isNotEmpty ?? false) ||
      (motherTongue?.trim().isNotEmpty ?? false) ||
      (languages?.isNotEmpty ?? false) ||
      (familyValues?.trim().isNotEmpty ?? false) ||
      (marriageViews?.trim().isNotEmpty ?? false) ||
      (ethnicity?.trim().isNotEmpty ?? false) ||
      minReligionImportance != null ||
      maxReligionImportance != null ||
      minCultureImportance != null ||
      maxCultureImportance != null ||
      (education?.trim().isNotEmpty ?? false) ||
      (occupation?.trim().isNotEmpty ?? false) ||
      annualIncome != null ||
      minIncome != null ||
      maxIncome != null ||
      (height?.trim().isNotEmpty ?? false) ||
      (minHeight?.trim().isNotEmpty ?? false) ||
      (maxHeight?.trim().isNotEmpty ?? false) ||
      (physicalStatus?.trim().isNotEmpty ?? false) ||
      (maritalStatus?.trim().isNotEmpty ?? false) ||
      (diet?.trim().isNotEmpty ?? false) ||
      (smoking?.trim().isNotEmpty ?? false) ||
      (drinking?.trim().isNotEmpty ?? false) ||
      (marriageIntention?.trim().isNotEmpty ?? false) ||
      requiresFamilyApproval != null ||
      mustBeReligious != null ||
      mustWantChildren != null ||
      mustBeNeverMarried != null ||
      locationRadius != null ||
      latitude != null ||
      longitude != null;

  bool get hasCriteria => hasQuery || hasFieldFilters;

  Map<String, dynamic> toQuery() {
    final m = <String, dynamic>{};
    final q = query?.trim();
    final c = city?.trim();
    final countryValue = country?.trim();
    final s = sort?.trim();
    final cur = cursor?.trim();
    final pg = preferredGender?.trim();

    if (q != null && q.isNotEmpty) m['q'] = q;
    if (minAge != null) m['ageMin'] = minAge;
    if (maxAge != null) m['ageMax'] = maxAge;
    if (c != null && c.isNotEmpty) m['city'] = c;
    if (countryValue != null && countryValue.isNotEmpty) {
      m['country'] = countryValue;
    }
    if (s != null && s.isNotEmpty) m['sort'] = s;
    if (cur != null && cur.isNotEmpty) m['cursor'] = cur;
    if (pg != null && pg.isNotEmpty) m['gender'] = pg;
    if (pageSize != null && pageSize! > 0) m['pageSize'] = pageSize;

    final r = religion?.trim();
    final rp = religiousPractice?.trim();
    final mt = motherTongue?.trim();
    final fv = familyValues?.trim();
    final mv = marriageViews?.trim();
    final eth = ethnicity?.trim();

    if (r != null && r.isNotEmpty) m['religion'] = r;
    if (rp != null && rp.isNotEmpty) m['religiousPractice'] = rp;
    if (mt != null && mt.isNotEmpty) m['motherTongue'] = mt;
    if (languages != null && languages!.isNotEmpty) m['languages'] = languages;
    if (fv != null && fv.isNotEmpty) m['familyValues'] = fv;
    if (mv != null && mv.isNotEmpty) m['marriageViews'] = mv;
    if (eth != null && eth.isNotEmpty) m['ethnicity'] = eth;
    if (minReligionImportance != null) {
      m['minReligionImportance'] = minReligionImportance;
    }
    if (maxReligionImportance != null) {
      m['maxReligionImportance'] = maxReligionImportance;
    }
    if (minCultureImportance != null) {
      m['minCultureImportance'] = minCultureImportance;
    }
    if (maxCultureImportance != null) {
      m['maxCultureImportance'] = maxCultureImportance;
    }

    final edu = education?.trim();
    final occ = occupation?.trim();
    if (edu != null && edu.isNotEmpty) m['education'] = edu;
    if (occ != null && occ.isNotEmpty) m['occupation'] = occ;
    if (annualIncome != null) m['annualIncome'] = annualIncome;
    if (minIncome != null) m['minIncome'] = minIncome;
    if (maxIncome != null) m['maxIncome'] = maxIncome;

    final h = height?.trim();
    final minh = minHeight?.trim();
    final maxh = maxHeight?.trim();
    final ps = physicalStatus?.trim();
    final ms = maritalStatus?.trim();
    if (h != null && h.isNotEmpty) m['height'] = h;
    if (minh != null && minh.isNotEmpty) m['minHeight'] = minh;
    if (maxh != null && maxh.isNotEmpty) m['maxHeight'] = maxh;
    if (ps != null && ps.isNotEmpty) m['physicalStatus'] = ps;
    if (ms != null && ms.isNotEmpty) m['maritalStatus'] = ms;

    final d = diet?.trim();
    final sm = smoking?.trim();
    final dr = drinking?.trim();
    if (d != null && d.isNotEmpty) m['diet'] = d;
    if (sm != null && sm.isNotEmpty) m['smoking'] = sm;
    if (dr != null && dr.isNotEmpty) m['drinking'] = dr;

    final mi = marriageIntention?.trim();
    if (mi != null && mi.isNotEmpty) m['marriageIntention'] = mi;
    if (requiresFamilyApproval != null) {
      m['requiresFamilyApproval'] = requiresFamilyApproval;
    }
    if (mustBeReligious != null) m['mustBeReligious'] = mustBeReligious;
    if (mustWantChildren != null) m['mustWantChildren'] = mustWantChildren;
    if (mustBeNeverMarried != null) {
      m['mustBeNeverMarried'] = mustBeNeverMarried;
    }

    if (locationRadius != null) m['locationRadius'] = locationRadius;
    if (latitude != null) m['latitude'] = latitude;
    if (longitude != null) m['longitude'] = longitude;

    return m;
  }

  Map<String, dynamic> toJson() => {
        if (query != null) 'query': query,
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (sort != null) 'sort': sort,
        if (cursor != null) 'cursor': cursor,
        if (pageSize != null) 'pageSize': pageSize,
        if (preferredGender != null) 'preferredGender': preferredGender,
        if (religion != null) 'religion': religion,
        if (religiousPractice != null) 'religiousPractice': religiousPractice,
        if (motherTongue != null) 'motherTongue': motherTongue,
        if (languages != null) 'languages': languages,
        if (familyValues != null) 'familyValues': familyValues,
        if (marriageViews != null) 'marriageViews': marriageViews,
        if (ethnicity != null) 'ethnicity': ethnicity,
        if (minReligionImportance != null)
          'minReligionImportance': minReligionImportance,
        if (maxReligionImportance != null)
          'maxReligionImportance': maxReligionImportance,
        if (minCultureImportance != null)
          'minCultureImportance': minCultureImportance,
        if (maxCultureImportance != null)
          'maxCultureImportance': maxCultureImportance,
        if (education != null) 'education': education,
        if (occupation != null) 'occupation': occupation,
        if (annualIncome != null) 'annualIncome': annualIncome,
        if (minIncome != null) 'minIncome': minIncome,
        if (maxIncome != null) 'maxIncome': maxIncome,
        if (height != null) 'height': height,
        if (minHeight != null) 'minHeight': minHeight,
        if (maxHeight != null) 'maxHeight': maxHeight,
        if (physicalStatus != null) 'physicalStatus': physicalStatus,
        if (maritalStatus != null) 'maritalStatus': maritalStatus,
        if (diet != null) 'diet': diet,
        if (smoking != null) 'smoking': smoking,
        if (drinking != null) 'drinking': drinking,
        if (marriageIntention != null)
          'marriageIntention': marriageIntention,
        if (requiresFamilyApproval != null)
          'requiresFamilyApproval': requiresFamilyApproval,
        if (mustBeReligious != null) 'mustBeReligious': mustBeReligious,
        if (mustWantChildren != null) 'mustWantChildren': mustWantChildren,
        if (mustBeNeverMarried != null)
          'mustBeNeverMarried': mustBeNeverMarried,
        if (locationRadius != null) 'locationRadius': locationRadius,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}

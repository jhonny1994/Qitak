import 'package:flutter/foundation.dart';

@immutable
class SearchFilterState {
  const SearchFilterState({
    this.categoryId,
    this.wilayaId,
    this.communeId,
    this.makeId,
    this.baseModel,
    this.year,
    this.priceMin,
    this.priceMax,
    this.condition,
    this.dealType,
    this.sort = 'newest',
  });

  final String? categoryId;
  final String? wilayaId;
  final String? communeId;
  final String? makeId;
  final String? baseModel;
  final int? year;
  final int? priceMin;
  final int? priceMax;
  final String? condition;
  final String? dealType;
  final String sort;

  SearchFilterState copyWith({
    String? categoryId,
    String? wilayaId,
    String? communeId,
    String? makeId,
    String? baseModel,
    int? year,
    int? priceMin,
    int? priceMax,
    String? condition,
    String? dealType,
    String? sort,
  }) {
    return SearchFilterState(
      categoryId: categoryId ?? this.categoryId,
      wilayaId: wilayaId ?? this.wilayaId,
      communeId: communeId ?? this.communeId,
      makeId: makeId ?? this.makeId,
      baseModel: baseModel ?? this.baseModel,
      year: year ?? this.year,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      condition: condition ?? this.condition,
      dealType: dealType ?? this.dealType,
      sort: sort ?? this.sort,
    );
  }

  SearchFilterState clearCommune() => SearchFilterState(
    categoryId: categoryId,
    wilayaId: wilayaId,
    makeId: makeId,
    baseModel: baseModel,
    year: year,
    priceMin: priceMin,
    priceMax: priceMax,
    condition: condition,
    dealType: dealType,
    sort: sort,
  );

  SearchFilterState clearModelAndYear() => SearchFilterState(
    categoryId: categoryId,
    wilayaId: wilayaId,
    communeId: communeId,
    makeId: makeId,
    priceMin: priceMin,
    priceMax: priceMax,
    condition: condition,
    dealType: dealType,
    sort: sort,
  );

  SearchFilterState clearYear() => SearchFilterState(
    categoryId: categoryId,
    wilayaId: wilayaId,
    communeId: communeId,
    makeId: makeId,
    baseModel: baseModel,
    priceMin: priceMin,
    priceMax: priceMax,
    condition: condition,
    dealType: dealType,
    sort: sort,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SearchFilterState &&
        other.categoryId == categoryId &&
        other.wilayaId == wilayaId &&
        other.communeId == communeId &&
        other.makeId == makeId &&
        other.baseModel == baseModel &&
        other.year == year &&
        other.priceMin == priceMin &&
        other.priceMax == priceMax &&
        other.condition == condition &&
        other.dealType == dealType &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(
    categoryId,
    wilayaId,
    communeId,
    makeId,
    baseModel,
    year,
    priceMin,
    priceMax,
    condition,
    dealType,
    sort,
  );
}

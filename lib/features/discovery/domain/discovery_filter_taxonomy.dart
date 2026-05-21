import 'package:flutter/foundation.dart';

@immutable
class DiscoveryCategoryOption {
  const DiscoveryCategoryOption({
    required this.id,
    required this.slug,
    this.riskLevel = 'green',
    this.requiresReview = false,
    this.minPhotos = 2,
  });

  final String id;
  final String slug;
  final String riskLevel;
  final bool requiresReview;
  final int minPhotos;
}

@immutable
class WilayaOption {
  const WilayaOption({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.communes,
  });

  final String id;
  final String name;
  final String arabicName;
  final List<CommuneOption> communes;
}

@immutable
class CommuneOption {
  const CommuneOption({
    required this.id,
    required this.name,
    required this.arabicName,
  });

  final String id;
  final String name;
  final String arabicName;
}

@immutable
class CarMakeOption {
  const CarMakeOption({
    required this.id,
    required this.name,
    required this.models,
  });

  final String id;
  final String name;
  final List<CarModelOption> models;
}

@immutable
class CarModelOption {
  const CarModelOption({
    required this.name,
    required this.years,
  });

  final String name;
  final List<int> years;
}

@immutable
class DiscoveryFilterTaxonomy {
  const DiscoveryFilterTaxonomy({
    required this.categories,
    required this.wilayas,
    required this.makes,
  });

  final List<DiscoveryCategoryOption> categories;
  final List<WilayaOption> wilayas;
  final List<CarMakeOption> makes;
}

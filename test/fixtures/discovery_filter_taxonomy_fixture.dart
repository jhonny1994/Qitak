import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';

const testDiscoveryFilterTaxonomy = DiscoveryFilterTaxonomy(
  categories: [
    DiscoveryCategoryOption(
      id: 'lighting',
      slug: 'lighting',
    ),
    DiscoveryCategoryOption(
      id: 'braking',
      slug: 'brakes',
      riskLevel: 'yellow',
      requiresReview: true,
    ),
    DiscoveryCategoryOption(
      id: 'engine',
      slug: 'engine',
      riskLevel: 'yellow',
      requiresReview: true,
    ),
    DiscoveryCategoryOption(
      id: 'body',
      slug: 'body',
    ),
  ],
  wilayas: [
    WilayaOption(
      id: '1',
      name: 'Adrar',
      arabicName: 'أدرار',
      communes: [
        CommuneOption(
          id: '1001',
          name: 'Adrar',
          arabicName: 'أدرار',
        ),
      ],
    ),
  ],
  makes: [
    CarMakeOption(
      id: 'Audi',
      name: 'Audi',
      models: [
        CarModelOption(name: 'TT Coupe', years: [2018, 2019]),
      ],
    ),
    CarMakeOption(
      id: 'Renault',
      name: 'Renault',
      models: [
        CarModelOption(name: 'Symbol', years: [2016]),
      ],
    ),
  ],
);

import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';

import 'fake_discovery_repository.dart';

const seededMarketplaceListings = <MarketplaceListing>[
  MarketplaceListing(
    id: 'listing-1',
    sellerUserId: 'seller-001',
    title: 'Headlight assembly',
    priceLabel: '18,500 DZD',
    locationLabel: 'Bab Ezzouar | Alger',
    fitmentLabel: 'Peugeot 308 | 2018',
    sellerLabel: 'Verified seller',
    rating: 4.8,
    threadId: 'l1',
    transactionId: 't1',
    categoryId: 'lighting',
    categoryLabel: 'Lighting',
    conditionLabel: 'Like new',
    description:
        'Verified fitment listing with clear lens condition and working mounts.',
    memberSinceLabel: 'Since 2023',
    exchangeAllowed: true,
    wilayaCode: '16',
    communeCode: '1601',
    brand: 'Peugeot',
    model: '308',
    year: 2018,
    sellerName: 'Samir Auto Parts',
    primaryImageUrl: 'https://example.com/headlight.png',
  ),
  MarketplaceListing(
    id: 'listing-2',
    sellerUserId: 'seller-001',
    title: 'Brake pad set',
    priceLabel: '7,500 DZD',
    locationLabel: 'Bir El Djir | Oran',
    fitmentLabel: 'Renault Symbol | 2016',
    sellerLabel: 'Business seller',
    rating: 4.1,
    threadId: 'l2',
    transactionId: 't2',
    categoryId: 'braking',
    categoryLabel: 'Brakes',
    conditionLabel: 'New',
    description:
        'Fresh stock brake pad kit for one fitment target, ready for pickup.',
    memberSinceLabel: 'Since 2022',
    wilayaCode: '31',
    communeCode: '3104',
    brand: 'Renault',
    model: 'Symbol',
    year: 2016,
    sellerName: 'Samir Auto Parts',
    primaryImageUrl: 'https://example.com/brakes.png',
  ),
];

const seededDiscoveryRepository = FakeDiscoveryRepository(
  listings: seededMarketplaceListings,
);

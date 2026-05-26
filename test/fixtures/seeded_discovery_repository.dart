import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';

import 'fake_discovery_repository.dart';

const seededMarketplaceListings = <MarketplaceListing>[
  MarketplaceListing(
    id: 'listing-1',
    sellerUserId: 'seller-001',
    title: 'Headlight assembly',
    priceAmount: 18500,
    sellerLabelCode: 'seller_label_verified',
    rating: 4.8,
    threadId: 'l1',
    transactionId: 't1',
    categoryId: 'lighting',
    categoryCode: 'lighting',
    conditionCode: 'like_new',
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
    priceAmount: 7500,
    sellerLabelCode: 'seller_label_business',
    rating: 4.1,
    threadId: 'l2',
    transactionId: 't2',
    categoryId: 'braking',
    categoryCode: 'braking',
    conditionCode: 'new',
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

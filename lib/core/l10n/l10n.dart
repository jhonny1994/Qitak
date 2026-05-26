import 'package:flutter/widgets.dart';

import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/generated/l10n.dart';

extension BuildContextL10nX on BuildContext {
  S get l10n => S.of(this);

  String languageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return l10n.languageNameEnglish;
      case 'fr':
        return l10n.languageNameFrench;
      case 'ar':
      default:
        return l10n.languageNameArabic;
    }
  }
}

extension AppRoleL10nX on S {
  String accountRoleLabel(AccountRole role) {
    switch (role) {
      case AccountRole.anonymous:
        return profileRoleAnonymous;
      case AccountRole.buyer:
        return profileRoleBuyer;
      case AccountRole.seller:
        return profileRoleSeller;
      case AccountRole.admin:
        return profileRoleAdmin;
      case AccountRole.superAdmin:
        return profileRoleSuperAdmin;
    }
  }

  String displayTransactionState(TransactionState state) {
    switch (state) {
      case TransactionState.intentCreated:
      case TransactionState.pendingSellerResponse:
        return transactionStateRequested;
      case TransactionState.sellerConfirmed:
        return transactionStateAccepted;
      case TransactionState.completed:
        return transactionStateCompleted;
      case TransactionState.expired:
        return transactionStateCancelled;
      case TransactionState.cancelled:
        return transactionStateCancelled;
      case TransactionState.disputeOpened:
      case TransactionState.disputeResolved:
        return transactionStateRejected;
    }
  }

  String transactionReferenceLabel(String id) {
    final match = RegExp(r'(\d+)$').firstMatch(id);
    final suffix = match?.group(1);
    if (suffix == null) {
      return id.toUpperCase();
    }
    return '#${suffix.padLeft(3, '0')}';
  }

  String localMarketplaceTitle(String raw) => raw;

  String localMarketplaceCategory(String raw) {
    switch (raw.toLowerCase()) {
      case 'lighting':
      case 'Lighting':
        return discoveryFilterLighting;
      case 'brakes':
      case 'braking':
      case 'Brakes':
        return categoryBraking;
      case 'engine':
      case 'engine-ignition':
      case 'Engine':
        return categoryEngineIgnition;
      case 'body':
      case 'body-exterior':
      case 'Body':
        return categoryBodyExterior;
      case 'cooling-system':
        return categoryCoolingSystem;
      case 'electrical-electronics':
        return categoryElectricalElectronics;
      case 'interior-controls':
        return categoryInteriorControls;
      case 'filters-maintenance':
        return categoryFiltersMaintenance;
      case 'wheels-tires':
        return categoryWheelsTires;
      case 'suspension-steering':
        return categorySuspensionSteering;
      case 'transmission-drivetrain':
        return categoryTransmissionDrivetrain;
      case 'exhaust-emissions':
        return categoryExhaustEmissions;
      default:
        return raw;
    }
  }

  String localMarketplaceCondition(String raw) {
    switch (raw.toLowerCase()) {
      case 'like_new':
      case 'Like new':
        return localListingConditionLikeNew;
      case 'new':
      case 'New':
        return localListingConditionNew;
      case 'used':
        return discoveryConditionUsed;
      default:
        return raw;
    }
  }

  String localMarketplaceSellerLabel(String raw) {
    switch (raw) {
      case 'Verified seller':
      case 'seller_label_verified':
        return localSellerLabelVerified;
      case 'Business seller':
      case 'seller_label_business':
        return localSellerLabelBusiness;
      default:
        return raw;
    }
  }

  String discoveryCategoryLabel(String slug) {
    switch (slug) {
      case 'lighting':
        return discoveryFilterLighting;
      case 'brakes':
      case 'braking':
        return categoryBraking;
      case 'engine':
      case 'engine-ignition':
        return categoryEngineIgnition;
      case 'body':
      case 'body-exterior':
        return categoryBodyExterior;
      case 'cooling-system':
        return categoryCoolingSystem;
      case 'electrical-electronics':
        return categoryElectricalElectronics;
      case 'interior-controls':
        return categoryInteriorControls;
      case 'filters-maintenance':
        return categoryFiltersMaintenance;
      case 'wheels-tires':
        return categoryWheelsTires;
      case 'suspension-steering':
        return categorySuspensionSteering;
      case 'transmission-drivetrain':
        return categoryTransmissionDrivetrain;
      case 'exhaust-emissions':
        return categoryExhaustEmissions;
      default:
        return slug;
    }
  }

  String discoveryConditionLabel(String condition) {
    switch (condition) {
      case 'new':
        return localListingConditionNew;
      case 'like_new':
        return localListingConditionLikeNew;
      case 'used':
        return discoveryConditionUsed;
      default:
        return condition;
    }
  }

  String discoveryDealTypeLabel(String value) {
    switch (value) {
      case 'buy':
        return discoveryDealTypeBuy;
      case 'buy_or_exchange':
        return discoveryDealTypeBuyOrExchange;
      default:
        return value;
    }
  }

  String discoverySortLabel(String value) {
    switch (value) {
      case 'newest':
        return discoverySortNewest;
      default:
        return value;
    }
  }

  String launchChecklistTitle(String name) {
    switch (name) {
      case 'flutter_analyze':
        return launchChecklistAnalyzeTitle;
      case 'flutter_test':
        return launchChecklistWidgetTestsTitle;
      case 'integration_test':
        return launchChecklistIntegrationTitle;
      case 'supabase_test_db':
        return launchChecklistDatabaseTitle;
      default:
        return name;
    }
  }

  String launchChecklistMeta(String name) {
    switch (name) {
      case 'flutter_analyze':
        return launchChecklistAnalyzeMeta;
      case 'flutter_test':
        return launchChecklistWidgetTestsMeta;
      case 'integration_test':
        return launchChecklistIntegrationMeta;
      case 'supabase_test_db':
        return launchChecklistDatabaseMeta;
      default:
        return name;
    }
  }

  String launchSnapshotSignalTitle(String key) {
    switch (key) {
      case 'auth':
        return releaseAreaAuth;
      case 'transactions':
        return releaseAreaTransactions;
      case 'messaging':
        return releaseSignalMessaging;
      case 'release_gates':
        return releaseGateResults;
      default:
        return key;
    }
  }
}

extension DiscoveryTaxonomyL10nX on BuildContext {
  String displayWilaya(WilayaOption option) {
    final code = Localizations.localeOf(this).languageCode;
    return code == 'ar' ? option.arabicName : option.name;
  }

  String displayCommune(CommuneOption option) {
    final code = Localizations.localeOf(this).languageCode;
    return code == 'ar' ? option.arabicName : option.name;
  }
}

extension MarketplaceListingL10nX on MarketplaceListing {
  String localizedTitle(S l10n) => l10n.localMarketplaceTitle(title);

  String localizedCategory(S l10n) =>
      l10n.localMarketplaceCategory(categoryCode);

  String localizedCondition(S l10n) =>
      l10n.localMarketplaceCondition(conditionCode);

  String localizedSellerLabel(S l10n) =>
      l10n.localMarketplaceSellerLabel(sellerLabelCode);

  String localizedPrice(S l10n) => '$priceAmount DZD';

  String localizedFitment(S l10n) {
    final parts = <String>[
      if (brand != null && brand!.isNotEmpty) brand!,
      if (model != null && model!.isNotEmpty) model!,
      if (year != null) year.toString(),
    ];
    return parts.join(' | ');
  }

  String localizedLocation(S l10n) {
    final commune = communeCode?.trim().isNotEmpty == true ? communeCode! : '-';
    final wilaya = wilayaCode?.trim().isNotEmpty == true ? wilayaCode! : '-';
    return '$commune | $wilaya';
  }
}

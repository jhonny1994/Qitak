import 'package:flutter/foundation.dart';

@immutable
class SellerApplication {
  const SellerApplication({
    required this.id,
    required this.userId,
    required this.sellerType,
    required this.businessName,
    required this.phone,
    required this.email,
    required this.wilayaId,
    required this.communeId,
    required this.bio,
    required this.verificationStatus,
    this.documents = const <SellerDocument>[],
    this.reviewReasonCode,
    this.reviewNote,
    this.submittedAt,
    this.reviewedAt,
  });

  final String id;
  final String userId;
  final String sellerType;
  final String businessName;
  final String phone;
  final String email;
  final String wilayaId;
  final String communeId;
  final String bio;
  final String verificationStatus;
  final List<SellerDocument> documents;
  final String? reviewReasonCode;
  final String? reviewNote;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  bool get isApproved => verificationStatus == 'approved';
  bool get isSubmitted => verificationStatus == 'submitted';
  bool get needsMoreInfo => verificationStatus == 'needs_more_info';
  bool get isRejected => verificationStatus == 'rejected';
}

@immutable
class SellerApplicationDraft {
  const SellerApplicationDraft({
    required this.sellerType,
    required this.businessName,
    required this.phone,
    required this.wilayaId,
    required this.communeId,
    required this.bio,
    required this.policiesAccepted,
    this.documents = const <SellerDocumentDraft>[],
  });

  final String sellerType;
  final String businessName;
  final String phone;
  final String wilayaId;
  final String communeId;
  final String bio;
  final bool policiesAccepted;
  final List<SellerDocumentDraft> documents;
}

@immutable
class SellerDocument {
  const SellerDocument({
    required this.id,
    required this.documentType,
    required this.storagePath,
    required this.uploadedAt,
    this.publicUrl,
  });

  final String id;
  final String documentType;
  final String storagePath;
  final DateTime uploadedAt;
  final String? publicUrl;
}

@immutable
class SellerDocumentDraft {
  const SellerDocumentDraft({
    required this.documentType,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String documentType;
  final String fileName;
  final String mimeType;
  final Uint8List bytes;
}

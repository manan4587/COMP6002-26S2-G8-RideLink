import 'package:flutter/material.dart';
import 'package:ridelink/core/constants/app_colors.dart';

/// Fixed standard driver document identifiers in Firestore
class DriverDocumentId {
  DriverDocumentId._();

  static const String drivingLicence = 'driving_licence';
  static const String vehicleRegistration = 'vehicle_registration';
  static const String vehicleInsurance = 'vehicle_insurance';
  static const String policeCheck = 'police_check';

  static const List<String> all = [
    drivingLicence,
    vehicleRegistration,
    vehicleInsurance,
    policeCheck,
  ];

  static const List<String> required = [
    drivingLicence,
    vehicleRegistration,
    vehicleInsurance,
  ];
}

/// Verification status for driver documents and credentials.
/// Strictly follows single values matching Cloud Firestore schema:
/// - notUploaded: Document has not been uploaded yet
/// - pending: Document has been uploaded and awaiting admin review
/// - verified: Approved and verified by administrator
/// - rejected: Rejected by administrator
/// - optional: Optional document not yet uploaded (e.g. Police Check)
enum DocumentVerificationStatus {
  notUploaded('not_uploaded', 'Not Uploaded'),
  pending('pending', 'In Review'),
  verified('verified', 'Verified'),
  rejected('rejected', 'Rejected'),
  optional('optional', 'Optional');

  final String value;
  final String label;

  const DocumentVerificationStatus(this.value, this.label);

  static DocumentVerificationStatus fromString(String? val) {
    if (val == null) return DocumentVerificationStatus.notUploaded;
    final s = val.trim().toLowerCase();
    if (s == 'verified') return DocumentVerificationStatus.verified;
    if (s == 'rejected') return DocumentVerificationStatus.rejected;
    if (s == 'pending' || s == 'in review' || s == 'in_review') {
      return DocumentVerificationStatus.pending;
    }
    if (s == 'optional') return DocumentVerificationStatus.optional;
    return DocumentVerificationStatus.notUploaded;
  }

  Color get primaryColor {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return const Color(0xFF16A34A);
      case DocumentVerificationStatus.rejected:
        return const Color(0xFFDC2626);
      case DocumentVerificationStatus.pending:
        return const Color(0xFFD97706);
      case DocumentVerificationStatus.optional:
        return AppColors.secondaryTextColor;
      case DocumentVerificationStatus.notUploaded:
        return AppColors.primaryColor;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return const Color(0xFFDCFCE7);
      case DocumentVerificationStatus.rejected:
        return const Color(0xFFFEE2E2);
      case DocumentVerificationStatus.pending:
        return const Color(0xFFFEF3C7);
      case DocumentVerificationStatus.optional:
        return const Color(0xFFF1F5F9);
      case DocumentVerificationStatus.notUploaded:
        return const Color(0xFFEFF6FF);
    }
  }

  Color get borderColor {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return const Color(0xFF86EFAC);
      case DocumentVerificationStatus.rejected:
        return const Color(0xFFFCA5A5);
      case DocumentVerificationStatus.pending:
        return const Color(0xFFFDE68A);
      case DocumentVerificationStatus.optional:
      case DocumentVerificationStatus.notUploaded:
        return AppColors.borderColor;
    }
  }

  Color get cardBorderColor {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return const Color(0xFF10B981);
      case DocumentVerificationStatus.rejected:
        return const Color(0xFFEF4444);
      case DocumentVerificationStatus.pending:
        return const Color(0xFFF59E0B);
      case DocumentVerificationStatus.optional:
      case DocumentVerificationStatus.notUploaded:
        return AppColors.borderColor;
    }
  }

  Color get cardShadowColor {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return const Color(0xFF10B981).withValues(alpha: 0.06);
      case DocumentVerificationStatus.rejected:
        return const Color(0xFFEF4444).withValues(alpha: 0.06);
      case DocumentVerificationStatus.pending:
        return const Color(0xFFF59E0B).withValues(alpha: 0.06);
      case DocumentVerificationStatus.optional:
      case DocumentVerificationStatus.notUploaded:
        return AppColors.primaryTextColor.withValues(alpha: 0.02);
    }
  }

  bool get isVerified => this == DocumentVerificationStatus.verified;
  bool get isRejected => this == DocumentVerificationStatus.rejected;
  bool get isPending => this == DocumentVerificationStatus.pending;
  bool get isNotUploaded => this == DocumentVerificationStatus.notUploaded;
  bool get isOptional => this == DocumentVerificationStatus.optional;
}


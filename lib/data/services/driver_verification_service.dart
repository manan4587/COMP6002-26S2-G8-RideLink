import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ridelink/core/enums/verification_status.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';

export 'package:ridelink/core/enums/verification_status.dart';

/// Service for driver identity & vehicle verification documents.
/// Stores image files in Firebase Storage and document records in `users/{userId}/docs/{doc_id}` subcollection.
class DriverVerificationService {
  DriverVerificationService._();
  static final DriverVerificationService instance =
      DriverVerificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      _firestore.collection(FirestoreCollections.users).doc(userId);

  CollectionReference<Map<String, dynamic>> _docsRef(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.docs);

  /// Normalizes any document type string into fixed standard document ID
  String normalizeDocId(String docType) {
    final clean = docType.trim().toLowerCase().replaceAll(' ', '_');
    if (DriverDocumentId.all.contains(clean)) return clean;
    if (clean.contains('licence') || clean.contains('license') || clean == 'dl') {
      return DriverDocumentId.drivingLicence;
    } else if (clean.contains('registration') || clean.contains('rego') || clean == 'vr') {
      return DriverDocumentId.vehicleRegistration;
    } else if (clean.contains('insurance') || clean == 'vi') {
      return DriverDocumentId.vehicleInsurance;
    } else if (clean.contains('police') || clean == 'pc') {
      return DriverDocumentId.policeCheck;
    }
    return clean;
  }

  /// Upload a file or bytes to Firebase Storage under `driver_documents/{userId}/{doc_id}.{ext}`
  Future<String> uploadToFirebaseStorage({
    required String userId,
    required String docType,
    File? file,
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      final cleanDocId = normalizeDocId(docType);
      final ext = fileName != null && fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'jpg';
      final contentType = (ext == 'png')
          ? 'image/png'
          : (ext == 'pdf')
              ? 'application/pdf'
              : 'image/jpeg';

      final storageRef = _storage
          .ref()
          .child('driver_documents/$userId/$cleanDocId.$ext');

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'user_id': userId,
          'doc_id': cleanDocId,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      if (file != null && await file.exists()) {
        debugPrint('[DriverVerification] Uploading file to Storage: ${storageRef.fullPath}');
        final task = await storageRef.putFile(file, metadata);
        final url = await task.ref.getDownloadURL();
        debugPrint('[DriverVerification] Storage upload successful: $url');
        return url;
      }

      if (bytes != null && bytes.isNotEmpty) {
        debugPrint('[DriverVerification] Uploading bytes to Storage: ${storageRef.fullPath}');
        final task = await storageRef.putData(bytes, metadata);
        final url = await task.ref.getDownloadURL();
        debugPrint('[DriverVerification] Storage upload successful: $url');
        return url;
      }

      debugPrint('[DriverVerification] No valid file or data to upload to Storage.');
      return '';
    } catch (e, stack) {
      debugPrint('[DriverVerification] Failed to upload to Storage: $e\n$stack');
      return '';
    }
  }

  /// Upload or update a single driver verification document to Firebase Storage and `users/{userId}/docs/{doc_id}` subcollection
  Future<String> uploadDriverDocument({
    required String userId,
    required String docType,
    required String title,
    required String fileName,
    File? file,
    Uint8List? bytes,
    String status = 'pending',
  }) async {
    try {
      final cleanDocId = normalizeDocId(docType);
      debugPrint('[DriverVerification] Saving $cleanDocId for user $userId to Storage & subcollection...');

      // 1. Upload to Firebase Storage
      final downloadUrl = await uploadToFirebaseStorage(
        userId: userId,
        docType: cleanDocId,
        file: file,
        bytes: bytes,
        fileName: fileName,
      );

      // Never fallback to local paths or fake URLs - throw clear exception on failure
      if (downloadUrl.isEmpty) {
        throw Exception('Failed to upload $title to storage. Please check your connection and try again.');
      }

      final validStatus = DocumentVerificationStatus.fromString(status).value;

      // 2. Save document record in subcollection: users/{userId}/docs/{doc_id}
      final docEntry = <String, dynamic>{
        'id': cleanDocId,
        'title': title,
        'user_id': userId,
        'file_name': fileName,
        'file_url': downloadUrl,
        'status': validStatus,
        'rejectionReason': null,
        'uploaded_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'verified_at': null,
        'verified_by': null,
      };

      await _docsRef(userId).doc(cleanDocId).set(docEntry, SetOptions(merge: true));

      // 3. Keep single is_verified_driver flag on parent user document
      await _userRef(userId).set({
        'is_verified_driver': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[DriverVerification] Document $cleanDocId saved to users/$userId/docs/$cleanDocId.');
      return downloadUrl;
    } catch (e, stack) {
      debugPrint('[DriverVerification] Error saving document $docType: $e\n$stack');
      rethrow;
    }
  }

  /// Submit full batch of driver verification documents upon registration
  Future<void> submitAllDriverDocuments({
    required String userId,
    required Map<String, Map<String, dynamic>> documents,
    Map<String, dynamic>? vehicleInfo,
  }) async {
    try {
      debugPrint('[DriverVerification] Submitting verification documents batch for user $userId to subcollection...');

      for (final entry in documents.entries) {
        final docType = entry.key;
        final docData = entry.value;
        final cleanDocId = normalizeDocId(docType);
        final title = docData['title']?.toString() ?? docType;
        final fileName = docData['fileName']?.toString() ??
            docData['file_name']?.toString() ??
            '$cleanDocId.jpg';
        final filePath = docData['filePath']?.toString() ?? docData['file_path']?.toString();
        final File? fileObj = (filePath != null && filePath.isNotEmpty) ? File(filePath) : null;
        final Uint8List? bytes = docData['bytes'] as Uint8List?;

        // 1. Upload to Firebase Storage
        final downloadUrl = await uploadToFirebaseStorage(
          userId: userId,
          docType: cleanDocId,
          file: fileObj,
          bytes: bytes,
          fileName: fileName,
        );

        if (downloadUrl.isEmpty) {
          throw Exception('Failed to upload $title to storage. Please check your connection and try again.');
        }

        // 2. Write to subcollection: users/{userId}/docs/{doc_id}
        final docEntry = <String, dynamic>{
          'id': cleanDocId,
          'title': title,
          'user_id': userId,
          'file_name': fileName,
          'file_url': downloadUrl,
          'status': DocumentVerificationStatus.pending.value,
          'rejectionReason': null,
          'uploaded_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'verified_at': null,
          'verified_by': null,
        };

        await _docsRef(userId).doc(cleanDocId).set(docEntry, SetOptions(merge: true));
      }

      // 3. Update users/{userId} parent document with single is_verified_driver flag
      final userUpdates = <String, dynamic>{
        'is_verified_driver': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (vehicleInfo != null && vehicleInfo.isNotEmpty) {
        final cleanVehicle = Map<String, dynamic>.from(vehicleInfo)
          ..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
        if (cleanVehicle.isNotEmpty) {
          userUpdates['vehicle'] = cleanVehicle;
        }
      }

      await _userRef(userId).set(userUpdates, SetOptions(merge: true));
      debugPrint('[DriverVerification] All documents saved to subcollection users/$userId/docs.');
    } catch (e, stack) {
      debugPrint('[DriverVerification] Batch submit failed: $e\n$stack');
      rethrow;
    }
  }

  /// Stream docs map directly from `users/{userId}/docs` subcollection
  Stream<Map<String, dynamic>> streamDriverDocsMap(String userId) {
    return _docsRef(userId).snapshots().map((snapshot) {
      final map = <String, dynamic>{};
      for (final doc in snapshot.docs) {
        map[doc.id] = doc.data();
      }
      return map;
    });
  }

  /// Fetch docs map once from `users/{userId}/docs` subcollection
  Future<Map<String, dynamic>> getDriverDocs(String userId) async {
    try {
      final snap = await _docsRef(userId).get();
      final map = <String, dynamic>{};
      for (final doc in snap.docs) {
        map[doc.id] = doc.data();
      }
      return map;
    } catch (e) {
      debugPrint('[DriverVerification] Failed to fetch docs: $e');
      return {};
    }
  }

  /// Update document status in `users/{userId}/docs/{doc_id}` (e.g. by admin panel)
  Future<void> updateDocumentStatus({
    required String userId,
    required String docType,
    required String status,
    String? rejectionReason,
  }) async {
    final cleanDocId = normalizeDocId(docType);
    final validStatus = DocumentVerificationStatus.fromString(status).value;

    await _docsRef(userId).doc(cleanDocId).set({
      'status': validStatus,
      'rejectionReason': validStatus == 'rejected' ? rejectionReason : null,
      'verified_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Save or update driver vehicle registration details to users/{userId}
  Future<void> saveVehicleDetails({
    required String userId,
    required String licensePlate,
    required String vehicleType,
    String? vehicleModel,
    String? vehicleColor,
  }) async {
    try {
      debugPrint('[DriverVerification] Saving vehicle details for user $userId to Firestore...');

      final String modelStr = vehicleModel?.trim() ?? '';
      final List<String> parts = modelStr.split(' ');
      final String make = parts.isNotEmpty ? parts[0] : '';
      final String model =
          parts.length > 1 ? parts.sublist(1).join(' ') : modelStr;

      final vehicleMap = {
        'make': make,
        'model': model,
        'licensePlate': licensePlate.trim(),
        'type': vehicleType.trim(),
        'color': vehicleColor?.trim() ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _userRef(userId).set({
        'vehicle': vehicleMap,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[DriverVerification] Vehicle details successfully saved to users collection.');
    } catch (e, stack) {
      debugPrint('[DriverVerification] Error saving vehicle details: $e\n$stack');
      rethrow;
    }
  }
}

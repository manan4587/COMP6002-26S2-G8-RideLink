import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';

/// Dedicated service for driver identity & vehicle verification documents
/// Storing image files in Firebase Storage and document metadata in `users/{userId}/docs` subcollection
class DriverVerificationService {
  DriverVerificationService._();
  static final DriverVerificationService instance =
      DriverVerificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _userDocsRef(String userId) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.docs);

  /// Upload a file or bytes to Firebase Storage under `driver_documents/{userId}/{docType}.{ext}`
  Future<String> uploadToFirebaseStorage({
    required String userId,
    required String docType,
    File? file,
    Uint8List? bytes,
    String? base64String,
    String? fileName,
  }) async {
    try {
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
          .child('driver_documents/$userId/$docType.$ext');

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'userId': userId,
          'docType': docType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      if (file != null && await file.exists()) {
        debugPrint('[DriverVerification] Uploading file to Storage: ${storageRef.fullPath}');
        final task = await storageRef.putFile(file, metadata);
        final url = await task.ref.getDownloadURL();
        debugPrint('[DriverVerification] Storage upload successful: $url');
        return url;
      }

      Uint8List? dataBytes = bytes;
      if (dataBytes == null && base64String != null && base64String.isNotEmpty) {
        String clean = base64String.trim();
        if (clean.contains(',')) {
          clean = clean.split(',').last;
        }
        dataBytes = base64Decode(clean);
      }

      if (dataBytes != null && dataBytes.isNotEmpty) {
        debugPrint('[DriverVerification] Uploading bytes to Storage: ${storageRef.fullPath}');
        final task = await storageRef.putData(dataBytes, metadata);
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

  /// Upload or update a single driver verification document to Firebase Storage and Firestore
  Future<String> uploadDriverDocument({
    required String userId,
    required String docType,
    required String title,
    required String fileName,
    File? file,
    String? base64Data,
    String status = 'Pending',
  }) async {
    try {
      debugPrint('[DriverVerification] Saving $docType for user $userId to Firebase Storage & Firestore...');

      // 1. Upload to Firebase Storage
      final downloadUrl = await uploadToFirebaseStorage(
        userId: userId,
        docType: docType,
        file: file,
        base64String: base64Data,
        fileName: fileName,
      );

      // 2. Save document record in Firestore subcollection users/{userId}/docs/{docType}
      final docMap = <String, dynamic>{
        'id': docType,
        'type': docType,
        'title': title,
        'fileName': fileName,
        'fileUrl': downloadUrl,
        'url': downloadUrl,
        'downloadUrl': downloadUrl,
        'status': status,
        'uploadedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (base64Data != null && base64Data.isNotEmpty) {
        docMap['base64'] = base64Data;
      }

      await _userDocsRef(userId).doc(docType).set(docMap, SetOptions(merge: true));

      // 3. Update parent user document driverStats
      final userUpdates = <String, dynamic>{
        'driverStats': {
          if (downloadUrl.isNotEmpty) '${docType}Url': downloadUrl,
          'lastDocumentUploadedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .set(userUpdates, SetOptions(merge: true));

      debugPrint('[DriverVerification] Document $docType successfully saved. Storage URL: $downloadUrl');
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
      debugPrint('[DriverVerification] Submitting batch verification documents for user $userId to Storage & Firestore...');
      final batch = _firestore.batch();
      final List<String> submittedTypes = [];
      final Map<String, dynamic> driverStatsUrls = {
        'lastDocumentUploadedAt': FieldValue.serverTimestamp(),
      };

      for (final entry in documents.entries) {
        final docType = entry.key;
        final docData = entry.value;
        final title = docData['title']?.toString() ?? docType;
        final fileName = docData['fileName']?.toString() ?? '$docType.jpg';
        final base64 = docData['base64']?.toString();
        final filePath = docData['filePath']?.toString();
        final File? fileObj = (filePath != null && filePath.isNotEmpty) ? File(filePath) : null;

        // Upload to Firebase Storage
        final downloadUrl = await uploadToFirebaseStorage(
          userId: userId,
          docType: docType,
          file: fileObj,
          base64String: base64,
          fileName: fileName,
        );

        if (downloadUrl.isNotEmpty) {
          driverStatsUrls['${docType}Url'] = downloadUrl;
        }

        final docRef = _userDocsRef(userId).doc(docType);
        final docPayload = <String, dynamic>{
          'id': docType,
          'type': docType,
          'title': title,
          'fileName': fileName,
          'fileUrl': downloadUrl,
          'url': downloadUrl,
          'downloadUrl': downloadUrl,
          'status': 'Pending',
          'uploadedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (base64 != null && base64.isNotEmpty) {
          docPayload['base64'] = base64;
        }

        batch.set(docRef, docPayload, SetOptions(merge: true));
        submittedTypes.add(docType);
      }

      // Update parent user profile
      final userRef =
          _firestore.collection(FirestoreCollections.users).doc(userId);
      final Map<String, dynamic> userPayload = {
        'isDriverVerificationSubmitted': true,
        'driverVerificationStatus': 'pending',
        'submittedDocuments': submittedTypes,
        'driverStats': driverStatsUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (vehicleInfo != null) {
        userPayload['vehicle'] = vehicleInfo;
      }

      batch.set(
        userRef,
        userPayload,
        SetOptions(merge: true),
      );

      await batch.commit();
      debugPrint('[DriverVerification] All verification documents committed successfully to Storage & Firestore.');
    } catch (e, stack) {
      debugPrint('[DriverVerification] Batch submit failed: $e\n$stack');
      rethrow;
    }
  }

  /// Stream all documents uploaded by a driver from `users/{userId}/docs`
  Stream<List<Map<String, dynamic>>> streamDriverDocuments(String userId) {
    return _userDocsRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Fetch a specific document for preview
  Future<Map<String, dynamic>?> getDriverDocument({
    required String userId,
    required String docType,
  }) async {
    try {
      final doc = await _userDocsRef(userId).doc(docType).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('[DriverVerification] Failed to fetch doc $docType: $e');
      return null;
    }
  }

  /// Update document status (e.g. by admin or simulation toggle)
  Future<void> updateDocumentStatus({
    required String userId,
    required String docType,
    required String status,
  }) async {
    await _userDocsRef(userId).doc(docType).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Save or update driver vehicle registration details to Firestore database
  Future<void> saveVehicleDetails({
    required String userId,
    required String licensePlate,
    required String vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    int totalSeats = 4,
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
        'totalSeats': totalSeats,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final batch = _firestore.batch();

      // 1. Update users/{userId} root profile
      final userRef =
          _firestore.collection(FirestoreCollections.users).doc(userId);
      batch.set(
        userRef,
        {
          'vehicle': vehicleMap,
          'driverStats': {
            'vehiclePlate': licensePlate.trim(),
            'vehicleType': vehicleType.trim(),
            'vehicleModel': modelStr,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // 2. Update users/{userId}/docs/vehicle_registration subcollection document
      final docRef = _userDocsRef(userId).doc('vehicle_registration');
      batch.set(
        docRef,
        {
          'id': 'vehicle_registration',
          'type': 'vehicle_registration',
          'title': 'Vehicle Registration',
          'vehicleNumber': licensePlate.trim(),
          'vehicleType': vehicleType.trim(),
          'vehicleModel': modelStr,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      debugPrint('[DriverVerification] Vehicle details successfully saved to Firestore.');
    } catch (e, stack) {
      debugPrint('[DriverVerification] Error saving vehicle details: $e\n$stack');
      rethrow;
    }
  }
}

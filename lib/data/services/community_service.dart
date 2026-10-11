import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';

/// Dedicated service for Commuter Communities & Community Rides
class CommunityService {
  CommunityService._();
  static final CommunityService instance = CommunityService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _communitiesRef =>
      _firestore.collection(FirestoreCollections.communities);

  CollectionReference<Map<String, dynamic>> get _tripsRef =>
      _firestore.collection(FirestoreCollections.rides);

  /// Stream all communities in real time from Firestore
  Stream<List<CommunityModel>> streamCommunities({String? role}) {
    if (_auth.currentUser == null) {
      return const Stream.empty();
    }
    return _communitiesRef.snapshots().map((snapshot) {
      try {
        if (snapshot.docs.isEmpty) {
          return <CommunityModel>[];
        }
        final currentUid = _auth.currentUser?.uid;
        final currentRole = role ?? Preferences.userRole;
        return snapshot.docs.map((doc) {
          return CommunityModel.fromMap(
            doc.data(),
            doc.id,
            currentUserId: currentUid,
            userRole: currentRole,
          );
        }).toList();
      } catch (e) {
        debugPrint('[CommunityService] Error processing communities: $e');
        return <CommunityModel>[];
      }
    });
  }

  /// Join a community
  Future<void> joinCommunity(String communityId, {String? role}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to join a community.');
    }

    final userRole = role ?? Preferences.userRole;
    final isDriver = userRole == 'driver';

    final batch = _firestore.batch();

    // 1. Save member profile in subcollection
    final memberRef = _firestore
        .collection(FirestoreCollections.communities)
        .doc(communityId)
        .collection(FirestoreCollections.communityMembers)
        .doc(user.uid);

    batch.set(
      memberRef,
      {
        'userId': user.uid,
        'name': user.displayName ??
            (Preferences.userName.isNotEmpty ? Preferences.userName : 'Member'),
        'role': userRole,
        'email': user.email ?? Preferences.userEmail,
        'phone': Preferences.userPhone,
        'joinedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 2. Update community member arrays and counts
    final commRef = _communitiesRef.doc(communityId);
    batch.set(
      commRef,
      {
        'memberIds': FieldValue.arrayUnion([user.uid]),
        if (isDriver) ...{
          'driverMemberIds': FieldValue.arrayUnion([user.uid]),
          'driversCount': FieldValue.increment(1),
        } else ...{
          'passengerMemberIds': FieldValue.arrayUnion([user.uid]),
          'passengersCount': FieldValue.increment(1),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 3. Update user profile's joinedCommunities list
    final userDocRef =
        _firestore.collection(FirestoreCollections.users).doc(user.uid);
    batch.set(
      userDocRef,
      {
        'joinedCommunities': FieldValue.arrayUnion([communityId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Leave a community
  Future<void> leaveCommunity(String communityId, {String? role}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRole = role ?? Preferences.userRole;
    final isDriver = userRole == 'driver';

    // Fetch existing doc to check current membership state safely
    final commDoc = await _communitiesRef.doc(communityId).get();
    final data = commDoc.data() ?? {};
    final driverMemberIds = (data['driverMemberIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final passengerMemberIds = (data['passengerMemberIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final bool wasInDrivers = driverMemberIds.contains(user.uid);
    final bool wasInPassengers = passengerMemberIds.contains(user.uid);

    final batch = _firestore.batch();

    // 1. Delete from subcollection
    final memberRef = _firestore
        .collection(FirestoreCollections.communities)
        .doc(communityId)
        .collection(FirestoreCollections.communityMembers)
        .doc(user.uid);

    batch.delete(memberRef);

    // 2. Remove from community member arrays and update counts safely
    final commRef = _communitiesRef.doc(communityId);
    final Map<String, dynamic> updateData = {
      'memberIds': FieldValue.arrayRemove([user.uid]),
      'driverMemberIds': FieldValue.arrayRemove([user.uid]),
      'passengerMemberIds': FieldValue.arrayRemove([user.uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (wasInDrivers || isDriver) {
      final currentDrivers = (data['driversCount'] as num?)?.toInt() ?? 0;
      updateData['driversCount'] = (currentDrivers - 1).clamp(0, 999999);
    }
    if (wasInPassengers || !isDriver) {
      final currentPassengers = (data['passengersCount'] as num?)?.toInt() ?? 0;
      updateData['passengersCount'] = (currentPassengers - 1).clamp(0, 999999);
    }

    batch.set(commRef, updateData, SetOptions(merge: true));

    // 3. Remove from user profile's joinedCommunities list
    final userDocRef =
        _firestore.collection(FirestoreCollections.users).doc(user.uid);
    batch.set(
      userDocRef,
      {
        'joinedCommunities': FieldValue.arrayRemove([communityId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Stream scheduled trips for a specific community
  Stream<List<TripModel>> streamCommunityTrips(String communityName) {
    return _tripsRef
        .where('communityName', isEqualTo: communityName)
        .where('status', isEqualTo: 'scheduled')
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data(), doc.id))
          .where((t) => t.availableSeats > 0)
          .toList();
      trips.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      return trips;
    });
  }
}

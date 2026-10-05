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

  bool _isSeeding = false;

  /// Seed initial community documents if the collection is empty
  Future<void> seedDefaultCommunitiesIfEmpty() async {
    if (_isSeeding || _auth.currentUser == null) return;
    _isSeeding = true;
    try {
      final snapshot = await _communitiesRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        _isSeeding = false;
        return;
      }

      debugPrint('[CommunityService] Seeding default communities into Firestore...');
      final batch = _firestore.batch();
      final defaultCommunities = [
        {
          'id': 'comm_curtin',
          'name': 'Curtin Community',
          'routeSummary': 'Landsdale → Curtin University',
          'commonTime': '7:30 AM - 9:00 AM',
          'description':
              'Daily shared rides for Curtin University students & staff commuting from northern and western suburbs.',
          'passengersCount': 12,
          'driversCount': 4,
          'nextRideTime': 'Tomorrow 8:00 AM',
          'nextRideSeatsOpen': 3,
          'icon': 'school',
          'memberIds': <String>[],
          'passengerMemberIds': <String>[],
          'driverMemberIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'comm_monash',
          'name': 'Monash Clayton Carpool',
          'routeSummary': 'Clayton ⇄ Eastern Suburbs',
          'commonTime': '8:00 AM - 9:30 AM',
          'description':
              'Daily campus commuters splitting petrol costs along Princes Highway and Wellington Rd.',
          'passengersCount': 28,
          'driversCount': 7,
          'nextRideTime': 'Tomorrow 8:30 AM',
          'nextRideSeatsOpen': 2,
          'icon': 'school',
          'memberIds': <String>[],
          'passengerMemberIds': <String>[],
          'driverMemberIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'comm_cbd',
          'name': 'Perth CBD Professionals',
          'routeSummary': 'North & South Corridors ⇄ St Georges Tce',
          'commonTime': '7:45 AM - 8:45 AM',
          'description':
              'Eco-conscious professionals carpooling to the city center with dedicated transit lane access.',
          'passengersCount': 45,
          'driversCount': 11,
          'nextRideTime': 'Tomorrow 7:45 AM',
          'nextRideSeatsOpen': 4,
          'icon': 'business',
          'memberIds': <String>[],
          'passengerMemberIds': <String>[],
          'driverMemberIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'comm_hospital',
          'name': 'Fiona Stanley Shift Workers',
          'routeSummary': 'Murdoch Hospital Precinct ⇄ South Metro',
          'commonTime': '6:30 AM & 2:30 PM Shift Change',
          'description':
              'Reliable healthcare workers sharing early morning and afternoon shift travel safely.',
          'passengersCount': 19,
          'driversCount': 5,
          'nextRideTime': 'Today 2:15 PM',
          'nextRideSeatsOpen': 1,
          'icon': 'hospital',
          'memberIds': <String>[],
          'passengerMemberIds': <String>[],
          'driverMemberIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'comm_ecu',
          'name': 'ECU Joondalup Campus Carpool',
          'routeSummary': 'Perth Northern Suburbs • Mitchell Fwy • Joondalup',
          'commonTime': '8:00 AM - 9:30 AM',
          'description':
              'Direct commuter rides connecting northern suburbs with Joondalup campus.',
          'passengersCount': 62,
          'driversCount': 18,
          'nextRideTime': 'Tomorrow 8:15 AM',
          'nextRideSeatsOpen': 3,
          'icon': 'school',
          'memberIds': <String>[],
          'passengerMemberIds': <String>[],
          'driverMemberIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'comm_fremantle',
          'name': 'Fremantle & Coastal Route',
          'routeSummary': 'Fremantle • Cottesloe • Subiaco • Perth City',
          'commonTime': '8:15 AM - 9:00 AM',
          'description':
              'Scenic coastal carpools along Stirling Hwy into Perth central business district.',
          'passengersCount': 45,
          'driversCount': 14,
          'nextRideTime': 'Tomorrow 8:00 AM',
          'nextRideSeatsOpen': 2,
          'icon': 'car',
          'memberIds': <String>[],
          'passengerMemberIds': <String>[],
          'driverMemberIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final comm in defaultCommunities) {
        final id = comm['id'] as String;
        final docRef = _communitiesRef.doc(id);
        batch.set(docRef, comm, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('[CommunityService] Default communities seeded successfully.');
    } catch (e) {
      debugPrint('[CommunityService] Failed to seed default communities: $e');
    } finally {
      _isSeeding = false;
    }
  }

  /// Stream all communities in real time from Firestore
  Stream<List<CommunityModel>> streamCommunities() {
    if (_auth.currentUser == null) {
      return const Stream.empty();
    }
    return _communitiesRef.snapshots().asyncMap((snapshot) async {
      try {
        if (snapshot.docs.isEmpty) {
          if (_auth.currentUser != null) {
            await seedDefaultCommunitiesIfEmpty();
          }
          return <CommunityModel>[];
        }
        final currentUid = _auth.currentUser?.uid;
        return snapshot.docs.map((doc) {
          return CommunityModel.fromMap(
            doc.data(),
            doc.id,
            currentUserId: currentUid,
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

    final batch = _firestore.batch();

    // 1. Delete from subcollection
    final memberRef = _firestore
        .collection(FirestoreCollections.communities)
        .doc(communityId)
        .collection(FirestoreCollections.communityMembers)
        .doc(user.uid);

    batch.delete(memberRef);

    // 2. Remove from community member arrays and update counts
    final commRef = _communitiesRef.doc(communityId);
    batch.set(
      commRef,
      {
        'memberIds': FieldValue.arrayRemove([user.uid]),
        if (isDriver) ...{
          'driverMemberIds': FieldValue.arrayRemove([user.uid]),
          'driversCount': FieldValue.increment(-1),
        } else ...{
          'passengerMemberIds': FieldValue.arrayRemove([user.uid]),
          'passengersCount': FieldValue.increment(-1),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

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


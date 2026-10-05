/// Centralized collection names and subcollection path helpers for Cloud Firestore.
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String driverVerifications = 'driver_verifications';
  static const String rides = 'rides';
  static const String bookings = 'bookings';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String communities = 'communities';
  static const String communityMembers = 'members';
  static const String reviews = 'reviews';
  static const String transactions = 'transactions';
  static const String safetyAlerts = 'safety_alerts';
  static const String supportTickets = 'support_tickets';
  static const String notifications = 'notifications';

  /// Subcollection name for driver verification documents: `users/{userId}/docs`
  static const String docs = 'docs';

  /// Subcollection path helper for driver verification documents: `users/{userId}/docs`
  static String userDocs(String userId) => '$users/$userId/$docs';

  /// Field key within `users/{userId}` for driver verification documents map:
  /// `users/{userId}.driverDocs = { [docId]: { "url": "...", "status": "pending"|"verified"|"rejected", ... } }`
  static const String driverDocsField = 'driverDocs';

  /// Subcollection path helper for chat messages: `chats/{chatId}/messages`
  static String chatMessages(String chatId) => '$chats/$chatId/$messages';

  /// Subcollection path helper for community members: `communities/{communityId}/members`
  static String communityMembersPath(String communityId) =>
      '$communities/$communityId/$communityMembers';
}


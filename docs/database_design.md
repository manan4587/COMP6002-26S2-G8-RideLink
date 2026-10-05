# RideLink Cloud Firestore Database Architecture & Schema Specification

This document provides a comprehensive technical overview and data dictionary of the Google Cloud Firestore database structure used by the **RideLink** mobile application, Cloud Functions, and administrative panel.

---

## 1. High-Level Architectural Overview

RideLink leverages Firebase Cloud Firestore as a scalable, NoSQL document-oriented real-time database.

### Core Architecture Pillars:

1. **Real-Time Data Flow**: Live listeners (`snapshots()`) update UI screens dynamically for Drivers and Passengers across all critical lifecycle events (Rides, Booking requests, Chat, Verification status).
2. **Push Notifications Integration**: A dedicated `notifications` collection listened to by Firebase Cloud Functions Gen 2 (`sendNotificationOnCreate`) triggers Firebase Cloud Messaging (FCM) push alerts.
3. **Decoupled Entities**:
   - `users`: Core profile, security roles, vehicle information, stats, emergency contacts, and active FCM token.
   - `rides`: Driver-published journeys, routes, coordinates, seats, and pricing.
   - `bookings`: Passenger reservation requests, confirmed seats, statuses, and fare totals.
   - `communities`: Verified commuter groups, campuses, and corporate carpooling hubs.
   - `support_tickets`: Customer care inquiries with threaded conversation histories.
   - `notifications`: Push notification delivery queue.

---

## 2. Global Collections Directory

| Collection Name           | Document ID Pattern                         | Purpose                                                                                               |
| :------------------------ | :------------------------------------------ | :---------------------------------------------------------------------------------------------------- |
| `users`                   | Firebase Auth UID (`u_...` or Firebase UID) | User identities, roles, profile, stats, emergency contacts, vehicle details, and FCM token.          |
| `users/{userId}/docs`     | Document ID (`driving_licence`, etc.)       | Driver verification documents subcollection.                                                          |
| `rides`                   | `dt_{timestamp}` or auto-ID                 | Driver published rides/trips.                                                                         |
| `rides/{tripId}/messages` | Auto-ID                                     | Real-time chat messages for an active ride.                                                           |
| `bookings`                | `bk_{timestamp}` or auto-ID                 | Ride seat reservation requests made by passengers.                                                    |
| `communities`             | Slug/ID (e.g. `comm_curtin`)                | Commuter and campus carpooling communities.                                                           |
| `support_tickets`         | `TICK-{timestamp}`                          | Customer care tickets and administrator responses.                                                    |
| `notifications`           | Auto-ID                                     | Push notification dispatch queue consumed by Cloud Functions Gen 2.                                   |

---

## 3. Detailed Data Models & Field Specifications

### 3.1 `users` Collection

Stores user profiles for both Passengers and Drivers.

```json
{
  "id": "abc123xyzUID",
  "fullName": "Jack Miller",
  "email": "jack.miller@example.com",
  "phoneNumber": "+61 412 345 678",
  "activeRole": "driver",
  "roles": ["passenger", "driver"],
  "isEmailVerified": true,
  "isOnline": true,
  "fcmToken": "eK...deviceTokenString...",
  "is_verified_driver": false,
  "passengerStats": {
    "rating": 4.9,
    "ratingCount": 18,
    "tripsCompleted": 18
  },
  "driverStats": {
    "rating": 5.0,
    "ratingCount": 42,
    "tripsCompleted": 42,
    "totalEarnings": 1250.00,
    "acceptanceRate": 0.98
  },
  "vehicle": {
    "make": "Toyota",
    "model": "Camry",
    "color": "Silver",
    "licensePlate": "1ABC234",
    "type": "Sedan"
  },
  "savedLocations": [
    {
      "id": "loc_1",
      "label": "Home",
      "address": "123 Hay Street, Perth WA",
      "location": {
        "_lat": -31.9505,
        "_long": 115.8605
      }
    }
  ],
  "emergencyContacts": [
    {
      "name": "Sarah Miller",
      "relationship": "Spouse",
      "phone": "+61 498 765 432"
    }
  ],
  "createdAt": "2026-10-01T08:00:00.000Z",
  "updatedAt": "2026-10-12T12:00:00.000Z"
}
```

#### Fields Breakdown:

- `id` _(string)_: Firebase Authentication UID.
- `fullName` _(string)_: User's display name (Avatar initials like "JM" are derived dynamically from fullName).
- `email` _(string)_: User's primary email.
- `phoneNumber` _(string)_: E.164 formatted phone number.
- `activeRole` _(string)_: Currently active interface mode: `"passenger"` | `"driver"`.
- `roles` _(array of strings)_: Allowed roles: `["passenger"]`, `["driver"]`, or `["passenger", "driver"]`.
- `isOnline` _(boolean)_: Real-time driver presence status (`true` = online/accepting rides, `false` = offline).
- `fcmToken` _(string)_: The singular, most current FCM device registration token for push notifications.
- `is_verified_driver` _(boolean)_: Singular verification flag set to `true` when admin approves the driver.
- `passengerStats` _(map)_: Passenger metrics (`rating`, `ratingCount`, `tripsCompleted`).
- `driverStats` _(map)_: Driver metrics (`rating`, `ratingCount`, `tripsCompleted`, `totalEarnings`, `acceptanceRate`).
- `vehicle` _(map)_: Driver vehicle configuration (`make`, `model`, `color`, `licensePlate`, `type`).

---

### 3.2 `docs` Subcollection Specification (`users/{user_id}/docs/{doc_id}`)

Driver documents are stored in an isolated subcollection: `users/{user_id}/docs/{doc_id}`. No spaces are used in any document ID, path, or key (strictly lowercase snake_case `_`).

#### Standard Document IDs (`doc_id`):

1. `driving_licence`: Valid Driver's Licence.
2. `vehicle_registration`: Vehicle Registration Certificate.
3. `vehicle_insurance`: Third-party / Comprehensive Vehicle Insurance.
4. `police_check`: National Police Certificate (Optional).

#### Document Status Enum (`DocumentVerificationStatus`):

```typescript
export enum DocumentVerificationStatus {
  PENDING = 'pending',
  VERIFIED = 'verified',
  REJECTED = 'rejected',
}
```

#### Document Schema (`users/{user_id}/docs/{doc_id}`):

```json
{
  "id": "driving_licence",
  "title": "Driving Licence",
  "user_id": "usr_98a7sd8f97a8sdf",
  "file_name": "driving_licence.jpg",
  "file_url": "https://firebasestorage.googleapis.com/v0/b/ridelink-d4408.firebasestorage.app/o/driver_documents%2Fusr_98a7sd8f97a8sdf%2Fdriving_licence.jpg?alt=media",
  "status": "pending", // DocumentVerificationStatus: "pending" | "verified" | "rejected"
  "rejectionReason": null,
  "uploaded_at": "2026-10-14T06:00:00.000Z",
  "updated_at": "2026-10-14T06:00:00.000Z",
  "verified_at": null,
  "verified_by": null
}
```

---

### 3.3 `rides` Collection

Stores driver-published journeys available for booking.

```json
{
  "id": "dt_1791523936000",
  "driverId": "jack_driver_uid",
  "driverName": "Jack Miller",
  "driverPhone": "+61 412 345 678",
  "driverRating": 5.0,
  "driverTotalRides": 42,
  "carModel": "Toyota Camry",
  "carPlate": "1ABC234",
  "carColor": "Silver",
  "originName": "Surat Central",
  "originAddress": "Surat Central Station, Gujarat",
  "originLat": 21.1702,
  "originLng": 72.8311,
  "destinationName": "Ahmedabad Airport",
  "destinationAddress": "Sardar Vallabhbhai Patel International Airport, Ahmedabad",
  "destinationLat": 23.0772,
  "destinationLng": 72.6347,
  "departureTime": "2026-10-13T08:00:00.000Z",
  "departureTimeString": "08:00 AM (Tomorrow, Oct 13)",
  "totalSeats": 3,
  "availableSeats": 2,
  "bookedSeats": 1,
  "pricePerSeat": 25.0,
  "communityName": "Surat Tech Commuters",
  "status": "scheduled",
  "allowLuggage": true,
  "allowPets": false,
  "allowSmoking": false,
  "createdAt": "2026-10-12T10:00:00.000Z",
  "updatedAt": "2026-10-12T11:00:00.000Z"
}
```

#### Status Enum:

- `"scheduled"`: Published and open for bookings.
- `"active"` / `"in_progress"`: Driver has started the journey.
- `"completed"`: Journey has concluded.
- `"cancelled"`: Ride cancelled by the driver.

---

### 3.4 `bookings` Collection

Stores booking requests submitted by passengers.

```json
{
  "id": "bk_1791524100000",
  "tripId": "dt_1791523936000",
  "driverId": "jack_driver_uid",
  "passengerId": "emma_passenger_uid",
  "passengerName": "Emma Watson",
  "passengerPhone": "+61 498 123 456",
  "passengerRating": 4.9,
  "requestedSeats": 1,
  "fare": 25.0,
  "pickupAddress": "Surat Central",
  "dropAddress": "Ahmedabad Airport",
  "status": "pending",
  "createdAt": "2026-10-12T11:00:00.000Z",
  "updatedAt": "2026-10-12T11:05:00.000Z"
}
```

#### Status Lifecycle:

1. `pending`: Passenger submits request -> Driver receives real-time request & push notification.
2. `accepted`: Driver approves -> `availableSeats` decreases, passenger receives push notification, booking confirmed.
3. `declined`: Driver declines -> Passenger receives push notification.
4. `cancelled`: Passenger or Driver cancels before ride initiation.

---

### 3.5 `rides/{tripId}/messages` Subcollection

Stores live, real-time carpool chat messages between the driver and accepted passengers.

#### Schema

```json
{
  "id": "msg_001",
  "senderId": "emma_passenger_uid",
  "senderName": "Emma Watson",
  "senderRole": "passenger",
  "message": "Hi Jack! I will be waiting near Platform 1 exit.",
  "timestamp": "2026-10-12T11:10:00.000Z"
}
```

#### Fields Breakdown

- `id` (String): Unique message document ID (`docRef.id`).
- `senderId` (String): Firebase Auth UID of the sender.
- `senderName` (String): Display name of the sender.
- `senderRole` (String): `"passenger"` or `"driver"`. Used by UI to render bubbles on the correct side (sender vs receiver).
- `message` (String): Trimmed message body.
- `timestamp` (FieldValue.serverTimestamp / Timestamp): Server timestamp used for strict sequential ordering (`orderBy('timestamp', descending: false)`).

#### Firestore Indexes:

- Single-field index on `timestamp` ascending enabled automatically.
- Path: `rides/{tripId}/messages`.

#### Clean Database Lifecycle:

1. Subcollection is initialized on the very first sent message.
2. Messages stream in real-time to both driver (`DriverRideChatPage`) and passenger (`RideChatPage`).
3. No hardcoded or dummy messages exist in UI state. If empty, a clean call-to-action view is rendered.
4. When a trip is deleted or archived by the administrator or driver, the messages subcollection is pruned along with the parent `rides` document.

---

### 3.6 `communities` Collection

Verified commuter networks and carpool groups.

```json
{
  "id": "comm_curtin",
  "name": "Curtin Community",
  "routeSummary": "Landsdale → Curtin University",
  "commonTime": "7:30 AM - 9:00 AM",
  "description": "Daily shared rides for Curtin University students & staff.",
  "passengersCount": 14,
  "driversCount": 5,
  "nextRideTime": "Tomorrow 8:00 AM",
  "nextRideSeatsOpen": 3,
  "icon": "school",
  "memberIds": ["user_1", "user_2"],
  "passengerMemberIds": ["user_1"],
  "driverMemberIds": ["user_2"],
  "createdAt": "2026-10-01T00:00:00.000Z",
  "updatedAt": "2026-10-12T12:00:00.000Z"
}
```

---

### 3.7 `notifications` Collection (Cloud Function FCM Pipeline)

Triggers Cloud Function Gen 2: `sendNotificationOnCreate`.

```json
{
  "title": "New Ride Request! 🚗",
  "body": "Emma Watson requested 1 seat for your trip (Surat Central → Ahmedabad Airport).",
  "userId": "jack_driver_uid",
  "status": "pending",
  "data": {
    "type": "ride_request",
    "tripId": "dt_1791523936000",
    "bookingId": "bk_1791524100000",
    "passengerId": "emma_passenger_uid",
    "passengerName": "Emma Watson",
    "seats": "1"
  },
  "sound": "default",
  "channelId": "high_importance_channel",
  "createdAt": "2026-10-12T11:00:01.000Z",
  "sentAt": "2026-10-12T11:00:02.000Z"
}
```

#### Processing Pipeline:

- When a new document is inserted with `"status": "pending"`, the Cloud Function extracts `userId`, resolves `users/{userId}.fcmToken`, constructs the FCM payload, and sends the notification.
- Upon dispatch, Cloud Function updates the document with `"status": "sent"` and `"messageId": "..."` (or `"status": "failed"` and `"error": "..."`).

---

### 3.8 `support_tickets` Collection

Customer care ticketing system.

```json
{
  "ticketId": "TICK-1791520000",
  "userId": "jack_driver_uid",
  "userName": "Jack Miller",
  "userEmail": "jack.miller@example.com",
  "userPhone": "+61 412 345 678",
  "userRole": "Driver",
  "subject": "Payout enquiry for weekend trip",
  "category": "Billing & Payments",
  "message": "Hi, I completed 3 trips on Saturday and would like to confirm payout timing.",
  "status": "Open",
  "priority": "Normal",
  "createdAt": "2026-10-10T09:00:00.000Z",
  "updatedAt": "2026-10-10T10:00:00.000Z",
  "messages": [
    {
      "id": "msg_001",
      "senderId": "jack_driver_uid",
      "senderName": "Jack Miller",
      "message": "Hi, I completed 3 trips on Saturday and would like to confirm payout timing.",
      "timestamp": "2026-10-10T09:00:00.000Z",
      "isAdmin": false
    },
    {
      "id": "msg_002",
      "senderId": "admin_uid",
      "senderName": "RideLink Support Support",
      "message": "Hello Jack, payouts are processed automatically every Monday morning.",
      "timestamp": "2026-10-10T10:00:00.000Z",
      "isAdmin": true
    }
  ]
}
```

---

## 4. Query Indexing Requirements

To ensure high performance across queries in Firestore, the following composite indexes should be deployed:

1. **`rides`**:
   - `status` ASC + `departureTime` ASC (Used for searching upcoming rides)
   - `driverId` ASC + `createdAt` DESC (Used for driver's trips history)
2. **`bookings`**:
   - `driverId` ASC + `createdAt` DESC (Used for real-time driver request streams)
   - `passengerId` ASC + `createdAt` DESC (Used for passenger trip history streams)
   - `tripId` ASC + `createdAt` DESC (Used for trip bookings lookup)
3. **`notifications`**:
   - `userId` ASC + `createdAt` DESC (Used for user notification center)
4. **`support_tickets`**:
   - `userId` ASC + `createdAt` DESC (Used for user ticket list)
   - `status` ASC + `createdAt` DESC (Used for admin ticket triage)

---

## 5. Security Rules Summary (`firestore.rules`)

- **Users**: Users can read and write their own profile (`request.auth.uid == userId`).
- **Driver Verification Docs**: Users can read and upload their own docs (`users/{userId}/docs`). Admin possesses full review rights.
- **Rides**: Authenticated users can query and read scheduled rides. Drivers can create and edit their own rides (`request.auth.uid == resource.data.driverId`).
- **Bookings**: Passengers can create bookings with their own ID. Drivers can read and update bookings for their trips.
- **Notifications**: System / authenticated users can create notification requests; users can read their own notifications.
- **Support Tickets**: Users can create and read their own support tickets; admin can manage all tickets.

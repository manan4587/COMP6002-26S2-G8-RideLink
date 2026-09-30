# RideLink – Communities Feature Specification for Admin Panel

This specification outlines the data model, database paths, required fields, and recommended admin panel UI/UX for creating and managing **Commuter Communities** in the RideLink application.

---

## 1. Overview & Mobile App Integration

Communities connect passengers and drivers who share regular commuting corridors (universities, business districts, hospital shifts, and major highway routes).

In the RideLink mobile app:
- **Passengers** view nearby communities on their Home and Communities tabs, search corridors, view route summaries/peak hours, and tap **"Join Group"** / **"Leave"**.
- **Drivers** view commuter networks on their Communities tab, join driver networks, and when publishing a ride via **"Create Ride"**, select target communities from a dynamic list populated directly from this collection.

---

## 2. Cloud Firestore Structure

### 2.1 Document Path
```
/communities/{communityId}
```
*Note: `{communityId}` can be a slug (e.g. `comm_curtin`, `comm_cbd`) or an auto-generated Firestore document ID.*

### 2.2 Subcollection Path
```
/communities/{communityId}/members/{userId}
```
*Stores individual member profiles who joined this community.*

### 2.3 Related Collection References
- **`users/{userId}`**: Contains an array field `joinedCommunities: [ "communityId", ... ]`.
- **`rides/{rideId}`**: Contains an optional field `communityName: "Curtin Community"` linking published trips to a community.

---

## 3. Schema & Field Definitions

### 3.1 Primary Document: `/communities/{communityId}`

| Field Name | Type | Required | Description & Accepted Values | Example |
| :--- | :--- | :---: | :--- | :--- |
| `name` | `string` | **Yes** | Display title of the community. | `"Curtin Community"` |
| `routeSummary` | `string` | **Yes** | Start and end destination / corridor summary. | `"Landsdale → Curtin University"` |
| `commonTime` | `string` | **Yes** | Common peak commuting hours. | `"7:30 AM - 9:00 AM"` |
| `description` | `string` | **Yes** | Detailed explanation of who uses this community and travel details. | `"Daily shared rides for Curtin University students & staff commuting from northern suburbs."` |
| `icon` | `string` | **Yes** | Icon keyword mapped by the mobile apps. Accepted: `school`, `business`, `hospital`, `car`. | `"school"` |
| `category` | `string` | No | Category tag: `university`, `corporate`, `healthcare`, `metro`, `corridor`. | `"university"` |
| `passengersCount` | `number` | **Yes** | Integer count of joined passengers (default `0`). Updated on join/leave. | `12` |
| `driversCount` | `number` | **Yes** | Integer count of joined drivers (default `0`). Updated on join/leave. | `4` |
| `nextRideTime` | `string` | No | Display text for the next upcoming community trip. Default: `"Tomorrow 8:00 AM"`. | `"Tomorrow 8:00 AM"` |
| `nextRideSeatsOpen` | `number` | No | Number of seats open in the next scheduled trip (default `3`). | `3` |
| `memberIds` | `array<string>` | **Yes** | Array of Firebase User UIDs who joined this community. | `["usr_123", "usr_456"]` |
| `passengerMemberIds` | `array<string>` | **Yes** | Array of Passenger UIDs. | `["usr_123"]` |
| `driverMemberIds` | `array<string>` | **Yes** | Array of Driver UIDs. | `["usr_456"]` |
| `coverImageUrl` | `string` | No | Optional banner or cover image URL. | `"https://..."` |
| `isActive` | `boolean` | **Yes** | Soft toggle to show/hide community in the apps (default `true`). | `true` |
| `createdAt` | `timestamp` | **Yes** | Timestamp of creation (use `FieldValue.serverTimestamp()`). | `Timestamp` |
| `updatedAt` | `timestamp` | **Yes** | Timestamp of last edit (use `FieldValue.serverTimestamp()`). | `Timestamp` |

---

### 3.2 Member Subcollection Document: `/communities/{communityId}/members/{userId}`

| Field Name | Type | Required | Description | Example |
| :--- | :--- | :---: | :--- | :--- |
| `userId` | `string` | **Yes** | Firebase Auth UID of the member. | `"7mK...89x"` |
| `name` | `string` | **Yes** | Full display name of the member. | `"Alex Turner"` |
| `role` | `string` | **Yes** | Role in this community: `'passenger'` or `'driver'`. | `"passenger"` |
| `email` | `string` | No | Member's contact email. | `"alex@example.com"` |
| `phone` | `string` | No | Member's contact phone number. | `"+61 400 123 456"` |
| `joinedAt` | `timestamp` | **Yes** | Timestamp when the user joined the community. | `Timestamp` |

---

## 4. Supported Icon Mapping

The mobile app supports the following standard `icon` values:

| `icon` String Value | App Icon Displayed | Recommended Use Case |
| :--- | :--- | :--- |
| `"school"` | Graduation Cap / Campus (`Icons.school_outlined`) | Universities, colleges, student carpools |
| `"business"` | Briefcase / Office (`Icons.business_center_outlined`) | CBD, financial corridors, corporate parks |
| `"hospital"` | Medical Cross (`Icons.local_hospital_outlined`) | Shift workers, healthcare workers, hospital staff |
| `"car"` | Automobile (`Icons.directions_car_outlined`) | Regional corridors, highway commutes, general carpools |

---

## 5. Sample Firestore Payloads

### 5.1 Creating a New Community Document
```json
{
  "name": "Curtin Community",
  "routeSummary": "Landsdale → Curtin University",
  "commonTime": "7:30 AM - 9:00 AM",
  "description": "Daily shared rides for Curtin University students & staff commuting from northern and western suburbs.",
  "icon": "school",
  "category": "university",
  "passengersCount": 0,
  "driversCount": 0,
  "nextRideTime": "Tomorrow 8:00 AM",
  "nextRideSeatsOpen": 3,
  "memberIds": [],
  "passengerMemberIds": [],
  "driverMemberIds": [],
  "coverImageUrl": "",
  "isActive": true,
  "createdAt": "2026-10-12T10:00:00Z",
  "updatedAt": "2026-10-12T10:00:00Z"
}
```

### 5.2 Member Document (`/communities/{communityId}/members/{userId}`)
```json
{
  "userId": "usr_948123984",
  "name": "Sarah Connor",
  "role": "passenger",
  "email": "sarah.connor@example.com",
  "phone": "+61 412 345 678",
  "joinedAt": "2026-10-12T10:05:00Z"
}
```

---

## 6. Admin Panel UI Requirements

### 6.1 Communities List Page
- **Table Columns**:
  1. **Icon & Name**: Display icon badge + Community Name.
  2. **Route Corridor**: `routeSummary`.
  3. **Peak Commute Hours**: `commonTime`.
  4. **Category**: Badge (`University`, `Corporate`, `Healthcare`, `Corridor`).
  5. **Counts**: `${driversCount} Drivers • ${passengersCount} Passengers`.
  6. **Status**: Toggle or Badge (`Active` / `Inactive`).
  7. **Actions**:
     - **Edit**: Opens Edit Community drawer/modal.
     - **Members**: Opens View Members drawer.
     - **Delete**: Prompts confirmation modal before deleting.
- **Top Controls**:
  - Search input: filters by `name` or `routeSummary`.
  - Filter dropdowns: Category filter, Active/Inactive filter.
  - **"+ Create Community"** button.

---

### 6.2 "Create / Edit Community" Form Modal
- **Form Inputs**:
  1. **Community Name** *(Input, required)* – e.g. `Monash Clayton Carpool`.
  2. **Route Summary** *(Input, required)* – e.g. `Clayton ⇄ Eastern Suburbs`.
  3. **Common / Peak Time** *(Input, required)* – e.g. `8:00 AM - 9:30 AM`.
  4. **Icon Type** *(Select dropdown, required)*:
     - `University / Campus (school)`
     - `Corporate / CBD (business)`
     - `Hospital / Healthcare (hospital)`
     - `Commuter Corridor (car)`
  5. **Category** *(Select dropdown)*:
     - `university`
     - `corporate`
     - `healthcare`
     - `metro`
     - `corridor`
  6. **Description** *(Textarea, required)*:
     - Detailed description for mobile users.
  7. **Next Ride Default Time** *(Input, optional, default: `"Tomorrow 8:00 AM"`)*.
  8. **Next Ride Open Seats** *(Number input, optional, default: `3`)*.
  9. **Cover Image URL** *(Optional image upload or URL input)*.
  10. **Active Status** *(Switch toggle, default: `true`)*.

---

### 6.3 "View Community Members" Drawer
- Displays the list of documents under `/communities/{communityId}/members`.
- Columns:
  1. Member Name (`name`).
  2. Role (`role` badge: Passenger [Blue] / Driver [Green]).
  3. Contact info (`email`, `phone`).
  4. Date Joined (`joinedAt`).
  5. Action: **Remove from community** (removes doc from subcollection and removes user UID from `memberIds`, `passengerMemberIds` or `driverMemberIds`, and decrements the corresponding count).

---

## 7. Security Rules for Firestore

Ensure the Firebase security rules permit read access to authenticated users and administrative writes:

```javascript
match /communities/{communityId} {
  // Any authenticated user can read active communities
  allow read: if request.auth != null;
  
  // Admin panel or authenticated users joining/leaving
  allow write: if request.auth != null;

  match /members/{userId} {
    // Authenticated users can read member list
    allow read: if request.auth != null;
    
    // User can add or remove themselves, or admin can manage
    allow write: if request.auth != null;
  }
}
```

---

## 8. Summary Checklist for Admin Developers

- [ ] Create Firestore collection `/communities`.
- [ ] Implement CRUD form matching the schema in Section 3.
- [ ] Support icon types: `school`, `business`, `hospital`, `car`.
- [ ] Initialize `memberIds: []`, `passengerMemberIds: []`, `driverMemberIds: []`, `passengersCount: 0`, `driversCount: 0` on creation.
- [ ] Connect "Members" view to subcollection `/communities/{communityId}/members`.
- [ ] Include soft toggle (`isActive`) for hiding/showing communities without losing member data.


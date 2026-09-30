# RideLink — Minimal Admin Panel Specification

> **Version:** 1.0 (Lean Edition)  
> **Purpose:** Practical, focused feature guide for building the RideLink Admin Operations Web Panel.

---

## 1. Core Modules Overview

The Admin Panel is intentionally kept lightweight and focused on 4 core sections:

```
┌─────────────────────────────────────────────────────────────┐
│                   RideLink Admin Panel                      │
├─────────────────┬──────────────────┬────────────────────────┤
│ 1. Dashboard    │ 2. Driver KYC    │ 3. Support Tickets     │
│    Metrics      │    Verification  │    (Driver & Passenger)│
├─────────────────┴──────────────────┴────────────────────────┤
│ 4. Allowed Locations / Service Areas                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Admin Dashboard (Platform Overview)

A simple, high-level command center showing key metrics across the platform.

### Key Metric Cards (KPIs)
| Metric Card | Description | Data Source |
| :--- | :--- | :--- |
| **Total Passengers** | Count of registered passenger accounts | `users` where `role = 'passenger'` |
| **Total Drivers** | Count of approved, active drivers | `users` where `role = 'driver'` and `isVerified = true` |
| **Pending Verifications** | Driver applications waiting for admin approval | `driver_verifications` where `status = 'pending'` |
| **Active Rides Today** | Rides currently ongoing or scheduled today | `rides` where `status IN ['active', 'scheduled']` |
| **Open Support Tickets** | Unresolved support queries | `support_tickets` where `status != 'resolved'` |

### Quick Lists
- **Recent Driver Registrations:** Latest 5 drivers who submitted verification documents.
- **Recent Support Tickets:** Latest 5 unanswered tickets from drivers or passengers.

---

## 3. Driver Verification (KYC) Module

Allows admins to review and approve/reject driver applications before they can publish rides.

### 3.1 Verification Applications Table
- **Columns:** Driver Name, Email, Phone, Vehicle Details (Make, Model, Plate), Submission Date, Status (`Pending`, `Approved`, `Rejected`), Action Button (`Review`).
- **Filter Tabs:** `[Pending (Needs Action)]`, `[Approved]`, `[Rejected]`.

### 3.2 Document Review Modal / Page
When an admin clicks **Review**:
1. **Driver & Vehicle Info:**
   - Full Name, Phone, Email
   - Vehicle Make, Model, Year, Plate Number, Total Passenger Seats
2. **Document Viewer:**
   - **Driver's License:** Front & back image preview (with zoom)
   - **Vehicle Registration Certificate (RC):** Document preview
   - **Vehicle Insurance:** Policy document preview & expiry date
3. **Admin Actions:**
   - **`[Approve Driver]` Button:**
     - Sets driver verification status to `approved`.
     - Automatically notifies the driver via push notification that their account is ready to publish rides.
   - **`[Reject Application]` Button:**
     - Opens a reason prompt:
       - *Options:* Blurry document, Expired license, Invalid insurance, Mismatched vehicle details, Other.
       - Optional note for driver.
     - Sets status to `rejected` and sends notification to driver with reason to re-upload.

---

## 4. Two-Way Support Chat System (Driver & Passenger)

A live, two-way query and support chat system connecting admins directly with drivers and passengers.

### 4.1 Tickets & Active Queries Inbox
- **Filter By:**
  - **User Role:** `All`, `Driver`, `Passenger`
  - **Status:** `Open`, `In Progress`, `Resolved (Locked)`
  - **Category:** `Fare / Payment`, `Ride Issue`, `Account / Profile`, `Other`
- **Table Columns:** Ticket ID, User Name, Role Badge (`Driver` / `Passenger`), Category, Subject, Last Message Date, Status (`Open` / `In Progress` / `Resolved 🔒`), Action (`Open Chat`).

### 4.2 Support Chat Window (Admin & Mobile App)
- **Active State (`Open` / `In Progress`):**
  - **Real-Time Two-Way Chat:** Admin can type replies in the Admin Panel; user/driver receives them instantly on their mobile app and can reply back.
  - **Full Context Panel:** Admin sees the user's phone, email, vehicle (if driver), and related Trip ID right next to the chat.
  - **Photo/File Attachments:** Both user and admin can send screenshot attachments.

- **Resolution & Locking Rule (`Resolved 🔒`):**
  - Admin clicks **`[Resolve Query]`**.
  - **Immediate Lock:** The thread is permanently marked as **`Resolved`** (`isLocked = true`).
  - **Disabled Input:** The text input in the mobile app and admin console is **completely disabled**.
  - **Lock Notice:** A clear banner is displayed:  
    *"🔒 This query has been marked as Resolved by Support. Further replies cannot be sent. If you need additional assistance, please open a new query."*
  - **No Re-opening:** Neither user nor driver can re-open or send messages to a resolved thread, preventing stale conversations and keeping support queues clean.

---

## 5. Allowed Locations & Service Areas

Defines which cities, zones, or corridors the app operates in, preventing rides outside supported areas.

### 5.1 Service Areas Table
- **Columns:** City/Area Name, State/Region, Status (`Active` / `Inactive`), Action (`Edit` / `Delete`).
- **Actions:**
  - **`[+ Add New Location]`:**
    - City / Region Name (e.g., "Austin Metro Area")
    - Center Latitude & Longitude
    - Operating Radius in KM (e.g., 35 km) or City Boundary name
    - Toggle `Active / Inactive`
  - **Mobile App Behavior:** When drivers create a ride or passengers search for a ride, the system checks if the pickup and destination fall within an active location. If not, the app shows: *"RideLink is not available in this area yet."*

---

## 6. Mobile App UI to Admin Panel Mapping

Quick reference showing how mobile screens connect to the Admin Panel:

| Mobile Screen (Flutter) | Connected Admin Panel Module | Action in Admin |
| :--- | :--- | :--- |
| **Driver Verification Upload** (`driver_verification_upload_view.dart`) | **Driver Verification** | Review uploaded license/RC and click Approve or Reject |
| **Verification Submitted** (`verification_submitted_view.dart`) | **Driver Verification** | Driver waits here until admin changes status from Pending |
| **Driver Support** (`driver_support_page.dart`) | **Support System** | Driver submits ticket $\to$ shows in admin ticket inbox |
| **Passenger Support** (`passenger_support_page.dart`) | **Support System** | Passenger submits ticket $\to$ shows in admin ticket inbox |
| **Create Ride / Search Ride** (`create_ride_page.dart` / `search_page.dart`) | **Allowed Locations** | Validates pickup/drop against admin's allowed cities list |
| **User Registration** (`create_account_view.dart`) | **Dashboard** | Increases Passenger/Driver counts on admin KPI cards |

---

## 7. Minimal Database Schemas (Firestore / SQL)

Only 4 collections/tables are required for this minimal setup:

### 7.1 `users` (Count & Profiles)
```json
{
  "id": "user_123",
  "fullName": "James Miller",
  "email": "james@example.com",
  "phone": "+1 555-0143",
  "role": "driver", // "driver" | "passenger"
  "isVerified": true, // false until approved by admin
  "createdAt": "2026-10-01T10:00:00Z"
}
```

### 7.2 `driver_verifications` (KYC Review)
```json
{
  "id": "verif_123",
  "driverId": "user_123",
  "driverName": "James Miller",
  "licenseNumber": "DL-98234-A",
  "licenseFrontUrl": "https://storage.ridelink.com/license_f.jpg",
  "licenseBackUrl": "https://storage.ridelink.com/license_b.jpg",
  "vehicleMake": "Toyota",
  "vehicleModel": "Camry",
  "vehiclePlate": "ABC-1234",
  "rcDocumentUrl": "https://storage.ridelink.com/rc.jpg",
  "insuranceDocUrl": "https://storage.ridelink.com/insurance.jpg",
  "status": "pending", // "pending" | "approved" | "rejected"
  "rejectionReason": null,
  "submittedAt": "2026-10-09T08:00:00Z",
  "reviewedAt": null
}
```

### 7.3 `support_tickets` (Two-Way Chat & Locking)
```json
{
  "id": "ticket_501",
  "userId": "user_123",
  "userName": "James Miller",
  "userRole": "driver", // "driver" | "passenger"
  "category": "Payment Issue",
  "subject": "Fare calculation question",
  "status": "resolved", // "open" | "in_progress" | "resolved"
  "isLocked": true, // locked permanently once resolved; no new messages permitted
  "messages": [
    {
      "id": "msg_001",
      "senderId": "user_123",
      "senderRole": "driver", // "driver" | "passenger" | "admin"
      "message": "I noticed an incorrect commission deduction on ride #402.",
      "timestamp": "2026-10-09T09:30:00Z"
    },
    {
      "senderId": "admin_ops_01",
      "senderRole": "admin",
      "message": "Hello James, we reviewed ride #402 and corrected the adjustment.",
      "timestamp": "2026-10-09T09:45:00Z"
    },
    {
      "senderId": "user_123",
      "senderRole": "driver",
      "message": "Thank you! I see it credited now.",
      "timestamp": "2026-10-09T09:50:00Z"
    }
  ],
  "resolvedAt": "2026-10-09T09:55:00Z",
  "resolvedByAdminId": "admin_ops_01",
  "createdAt": "2026-10-09T09:30:00Z"
}
```

### 7.4 `allowed_locations` (Service Areas)
```json
{
  "id": "loc_01",
  "cityName": "Austin",
  "state": "Texas",
  "centerLat": 30.2672,
  "centerLng": -97.7431,
  "radiusKm": 40.0,
  "isActive": true
}
```

---

## 8. Minimal Admin API Endpoints

```
# Dashboard Stats
GET    /api/admin/dashboard/stats           -> Returns counts for drivers, passengers, pending verifications, tickets

# Driver Verification
GET    /api/admin/verifications?status=pending -> List driver verification requests
GET    /api/admin/verifications/:id         -> View driver application details & document images
POST   /api/admin/verifications/:id/approve -> Approve driver
POST   /api/admin/verifications/:id/reject  -> Reject driver with reason

# Support Two-Way Chat & Tickets
GET    /api/admin/tickets?status=open       -> List support queries
GET    /api/admin/tickets/:id               -> View full chat thread history
POST   /api/admin/tickets/:id/messages      -> Send message (Admin or User). Returns 403 Forbidden if isLocked=true
POST   /api/admin/tickets/:id/resolve       -> Mark ticket as RESOLVED & permanently lock thread (disables user/driver input)

# Allowed Locations
GET    /api/admin/locations                 -> List allowed service locations
POST   /api/admin/locations                 -> Add new allowed city / area
PUT    /api/admin/locations/:id             -> Edit location or toggle active/inactive
DELETE /api/admin/locations/:id             -> Remove location
```

# RideLink Customer Support System — Admin Integration & Architecture Guide

This document describes the complete architecture, data models, Firestore collection structures, queries, real-time message exchange, status lifecycle, push notification strategy, and security rules for the **RideLink Support & Help Desk System**.

Share this document with the backend and admin portal engineering teams to build the Admin Support Console.

---

## 1. Overview & Architecture

The RideLink Customer Support System enables both **Passengers** and **Drivers** to report issues, ask questions, and chat live in real-time with RideLink Support Agents & Administrators.

```
+--------------------------+       +--------------------------+
|  Passenger Mobile App    |       |    Driver Mobile App     |
| (PassengerSupportPage)   |       |   (DriverSupportPage)    |
| (PassengerSupportChat)   |       |  (DriverSupportChatPage) |
+------------+-------------+       +------------+-------------+
             |                                  |
             |   Real-time Snapshot Listener    |
             |   (AuthService stream)           |
             v                                  v
+-------------------------------------------------------------+
|             Cloud Firestore Collection: `support_tickets`    |
+-------------------------------------------------------------+
                               ^
                               |
                               | (Admin Reads / Writes / Status)
                               v
               +-------------------------------+
               |    RideLink Admin Portal      |
               | (Web Dashboard / Support CRM) |
               +-------------------------------+
```

---

## 2. Cloud Firestore Schema

### Collection: `support_tickets`

Document ID: `ticketId` (e.g. `PS-4820193` or `TCK-8302194` or Firestore Auto-ID).

| Field Name | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `ticketId` | `String` | Unique human-readable ticket ID | `"PS-4820193"` / `"TCK-8302194"` |
| `userId` | `String` | Firebase Auth UID of requester | `"Rylx3ac5qoaXSh0G8MJE9Rw5zfi2"` |
| `userName` | `String` | Requester full name | `"Manan Patel"` |
| `userEmail` | `String` | Registered email address | `"manan@example.com"` |
| `userPhone` | `String` | Registered mobile contact | `"+61 412 345 678"` |
| `userRole` | `String` | User type | `"passenger"` or `"driver"` |
| `category` | `String` | Issue category (see categories below) | `"Cash Payments & Fares"` |
| `subject` | `String` | Summary title of the ticket | `"Dispute regarding trip to Curtin Uni"` |
| `message` | `String` | Initial inquiry description | `"The driver charged more cash than agreed."` |
| `status` | `String` | Lifecycle state | `"Open"`, `"In Progress"`, `"Resolved"` |
| `priority` | `String` | Support priority level | `"Normal"`, `"High"`, `"Urgent"` |
| `assignedAdminId` | `String?` | UID or email of assigned support agent | `"admin_alex@ridelink.com"` |
| `createdAt` | `Timestamp` | Ticket creation timestamp | `FieldValue.serverTimestamp()` |
| `updatedAt` | `Timestamp` | Last modification / message timestamp | `FieldValue.serverTimestamp()` |
| `resolvedAt` | `Timestamp?` | When marked resolved | `FieldValue.serverTimestamp()` |
| `messages` | `Array<Map>` | Array of sequential chat messages | *(See message structure below)* |

---

### Message Object Structure (Inside `messages` Array)

Each item in `messages`:

```json
{
  "id": "msg_1728492019302",
  "senderRole": "passenger", 
  "senderName": "Manan Patel",
  "message": "Hello, I haven't received my refund for yesterday's ride.",
  "timestamp": "2026-10-09T14:32:00.000Z"
}
```

#### Roles for `senderRole`:
- `"passenger"`: Message sent by passenger mobile app.
- `"driver"`: Message sent by driver mobile app.
- `"admin"`: Message sent by Support Admin Console.

---

## 3. Categories Reference

### Passenger Categories:
1. `Cash Payments & Fares`
2. `Booking & Ride Scheduling`
3. `Driver / Trip Issue`
4. `Lost Property`
5. `Account & Profile`
6. `Other Inquiries`

### Driver Categories:
1. `Verification & Documents`
2. `Ride Scheduling & Routes`
3. `Cash Payments & Fares`
4. `Passenger Issue`
5. `App Bug or Technical Support`
6. `Other Inquiries`

---

## 4. Admin Portal Implementation Guide

### 4.1. Querying Tickets

1. **All Active Tickets (Ordered by Latest First)**:
   ```javascript
   db.collection('support_tickets')
     .orderBy('updatedAt', 'desc')
     .onSnapshot((snapshot) => {
       const tickets = snapshot.docs.map(doc => doc.data());
       renderTickets(tickets);
     });
   ```

2. **Filter by Role**:
   ```javascript
   db.collection('support_tickets')
     .where('userRole', '==', 'driver') // or 'passenger'
     .orderBy('updatedAt', 'desc');
   ```

3. **Filter by Status**:
   ```javascript
   db.collection('support_tickets')
     .where('status', 'in', ['Open', 'In Progress'])
     .orderBy('updatedAt', 'desc');
   ```

---

### 4.2. Sending an Admin Reply to a Ticket

When an admin types a reply in the Admin CRM:

```javascript
import { doc, updateDoc, arrayUnion, serverTimestamp } from 'firebase/firestore';

async function sendAdminReply(ticketId, adminName, replyText) {
  const ticketRef = doc(db, 'support_tickets', ticketId);
  const messageData = {
    id: `admin_msg_${Date.now()}`,
    senderRole: 'admin',
    senderName: adminName || 'RideLink Support',
    message: replyText.trim(),
    timestamp: new Date().toISOString(),
  };

  await updateDoc(ticketRef, {
    messages: arrayUnion(messageData),
    status: 'In Progress', // Automatically change from 'Open' to 'In Progress' upon agent reply
    updatedAt: serverTimestamp(),
  });
}
```

> **Instant Sync**: As soon as this write occurs, the mobile app's `streamUserSupportTickets` listener triggers instantly, appending the reply to the user's screen in real-time with zero delay.

---

### 4.3. Changing Status & Resolving a Ticket

When the inquiry is resolved:

```javascript
async function resolveTicket(ticketId) {
  const ticketRef = doc(db, 'support_tickets', ticketId);
  const closingMessage = {
    id: `sys_res_${Date.now()}`,
    senderRole: 'admin',
    senderName: 'RideLink Support',
    message: 'This query has been marked as Resolved by Support. The conversation is now closed.',
    timestamp: new Date().toISOString(),
  };

  await updateDoc(ticketRef, {
    status: 'Resolved',
    resolvedAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    messages: arrayUnion(closingMessage),
  });
}
```

> **Client Reaction**: When `status` becomes `'Resolved'`, the mobile app locks the text input bar, displays the green `Resolved` badge, and shows:
> *"This query has been marked as Resolved by Support. Further replies are disabled."*

---

## 5. Push Notifications Strategy (Cloud Functions)

To notify users when an admin replies (and notify admins when a new query arrives):

### Recommended Firebase Cloud Function:
```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onSupportTicketUpdated = functions.firestore
  .document('support_tickets/{ticketId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    const beforeMsgs = beforeData.messages || [];
    const afterMsgs = afterData.messages || [];

    // Check if new message added
    if (afterMsgs.length > beforeMsgs.length) {
      const latestMsg = afterMsgs[afterMsgs.length - 1];

      // If Admin replied, push notify the user (passenger or driver)
      if (latestMsg.senderRole === 'admin') {
        const userDoc = await admin.firestore().collection('users').doc(afterData.userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          await admin.messaging().send({
            token: fcmToken,
            notification: {
              title: 'RideLink Support Reply',
              body: latestMsg.message,
            },
            data: {
              type: 'support_chat',
              ticketId: afterData.ticketId,
            },
          });
        }
      }
    }
  });
```

---

## 6. Recommended Firestore Security Rules

Ensure users can only view and post to their own tickets, while authenticated administrators have full read/write access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Support tickets collection
    match /support_tickets/{ticketId} {
      
      // Helper function to check if caller is an admin
      function isAdmin() {
        return request.auth != null && 
               request.auth.token.admin == true; // Custom Claim
      }
      
      // Helper to check if caller is ticket owner
      function isOwner() {
        return request.auth != null && 
               resource.data.userId == request.auth.uid;
      }
      
      // Read: Owner or Admin
      allow read: if request.auth != null && (resource.data.userId == request.auth.uid || isAdmin());
      
      // Create: Authenticated users can create tickets for themselves
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      
      // Update:
      // 1. User can append messages to their own open tickets
      // 2. Admin can update status, assign agent, and append messages
      allow update: if request.auth != null && (
        isAdmin() || 
        (isOwner() && resource.data.status != 'Resolved')
      );
      
      // Delete: Only admins can delete tickets
      allow delete: if isAdmin();
    }
  }
}
```

---

## 7. Direct Support Helplines

The RideLink application has built-in immediate escalation triggers:
- **Australian Emergency Services**: `000`
- **RideLink 24/7 Safety Helpline**: `1800 743 354` (`1800 RIDELINK`)
- **Safety Email Desk**: `safety@ridelink.com`
- **General Support Email Desk**: `support@ridelink.com`


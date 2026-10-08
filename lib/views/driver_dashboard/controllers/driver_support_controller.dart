import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/models/driver/driver_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/support_service.dart';

export 'package:ridelink/data/models/driver/driver_models.dart';

class DriverSupportController extends GetxController {
  // Support Tickets List
  final RxList<SupportTicketModel> supportTickets = <SupportTicketModel>[].obs;

  StreamSubscription? _supportTicketsSubscription;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.instance.currentUser;
    if (user != null) {
      subscribeToSupportTickets(user.uid);
    }

    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u != null) {
        subscribeToSupportTickets(u.uid);
      } else {
        clearState();
      }
    });
  }

  void clearState() {
    _supportTicketsSubscription?.cancel();
    _supportTicketsSubscription = null;
    supportTickets.clear();
  }

  void subscribeToSupportTickets(String uid) {
    _supportTicketsSubscription?.cancel();
    _supportTicketsSubscription =
        SupportService.instance.streamUserSupportTickets(uid).listen((ticketsData) {
      if (ticketsData.isEmpty) {
        supportTickets.clear();
        return;
      }

      final List<SupportTicketModel> loaded = [];
      for (final data in ticketsData) {
        final ticketId = data['ticketId']?.toString() ?? '';
        final subject = data['subject']?.toString() ?? '';
        final category = data['category']?.toString() ?? '';
        final message = data['message']?.toString() ?? '';
        final status = (data['isLocked'] == true && data['status'] == null)
            ? 'Resolved'
            : SupportTicketModel.normalizeStatus(data['status']?.toString());
        final createdAt = (data['createdAt'] is Timestamp)
            ? (data['createdAt'] as Timestamp).toDate()
            : (DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                DateTime.now());

        final msgsList = (data['messages'] as List<dynamic>? ?? []).map((m) {
          return SupportChatMessageModel(
            id: m['id']?.toString() ?? 'm_0',
            senderRole: m['senderRole']?.toString() ?? 'driver',
            senderName: m['senderName']?.toString() ?? '',
            message: m['message']?.toString() ?? '',
            timestamp: DateTime.tryParse(m['timestamp']?.toString() ?? '') ??
                DateTime.now(),
          );
        }).toList();

        final existing = supportTickets.firstWhereOrNull((t) => t.id == ticketId);
        if (existing != null) {
          existing.status.value = status;
          existing.messages.assignAll(msgsList);
          loaded.add(existing);
        } else {
          loaded.add(
            SupportTicketModel(
              id: ticketId,
              subject: subject,
              category: category,
              message: message,
              createdAt: createdAt,
              status: status,
              initialMessages: msgsList,
            ),
          );
        }
      }

      loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      supportTickets.assignAll(loaded);
    },
    onError: (err) {
      debugPrint('[DriverSupportController] Support tickets stream error: $err');
    },
  );
  }

  // Submit Support Ticket to Firestore
  Future<SupportTicketModel?> submitSupportTicket({
    required String subject,
    required String category,
    required String message,
  }) async {
    final now = DateTime.now();
    final ticketId = 'TCK-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final name = Preferences.userName.isNotEmpty ? Preferences.userName : 'Driver';
    final email = Preferences.userEmail;
    final phone = Preferences.userPhone;

    final newTicket = SupportTicketModel(
      id: ticketId,
      subject: subject,
      category: category,
      message: message,
      createdAt: now,
      status: 'Open',
      initialMessages: [
        SupportChatMessageModel(
          id: 'msg_${now.millisecondsSinceEpoch}',
          senderRole: 'driver',
          senderName: name,
          message: message,
          timestamp: now,
        ),
      ],
    );

    try {
      await SupportService.instance.createSupportTicket(
        ticketId: newTicket.id,
        subject: subject,
        category: category,
        message: message,
        userRole: 'driver',
        userName: name,
        userEmail: email,
        userPhone: phone,
      );

      final existingIdx =
          supportTickets.indexWhere((t) => t.id == newTicket.id);
      if (existingIdx != -1) {
        supportTickets[existingIdx] = newTicket;
      } else {
        supportTickets.insert(0, newTicket);
      }

      AppSnackBar.success(
        message:
            'Support query submitted! You can now chat with our Admin team in this thread.',
      );
      return newTicket;
    } catch (e) {
      debugPrint('[DriverSupportController] Failed to save support ticket: $e');
      AppSnackBar.error(
        message:
            'Failed to save ticket to database: ${AuthService.instance.getFriendlyErrorMessage(e)}',
      );
      return null;
    }
  }

  // Send message in active Support Chat
  Future<void> sendSupportChatMessage({
    required String ticketId,
    required String text,
  }) async {
    final ticket = supportTickets.firstWhereOrNull((t) => t.id == ticketId);
    if (ticket == null) return;

    if (ticket.isLocked) {
      AppSnackBar.warning(
        message:
            'This query has been marked as Resolved and cannot receive new replies.',
      );
      return;
    }

    final now = DateTime.now();
    final name = Preferences.userName.isNotEmpty ? Preferences.userName : 'Driver';

    final newMsg = SupportChatMessageModel(
      id: 'msg_${now.millisecondsSinceEpoch}',
      senderRole: 'driver',
      senderName: name,
      message: text.trim(),
      timestamp: now,
    );
    ticket.messages.add(newMsg);

    try {
      await SupportService.instance.addSupportChatMessage(
        ticketId: ticketId,
        message: text.trim(),
        senderRole: 'driver',
        senderName: name,
      );
    } catch (e) {
      debugPrint('[DriverSupportController] Failed to send support message: $e');
      AppSnackBar.error(
        message:
            'Failed to send message: ${AuthService.instance.getFriendlyErrorMessage(e)}',
      );
    }
  }

  // Admin marks query as Resolved and locks conversation
  void resolveSupportTicket(String ticketId) {
    final ticket = supportTickets.firstWhereOrNull((t) => t.id == ticketId);
    if (ticket == null) return;

    ticket.status.value = 'Resolved';
    final now = DateTime.now();
    ticket.messages.add(
      SupportChatMessageModel(
        id: 'msg_res_${now.millisecondsSinceEpoch}',
        senderRole: 'admin',
        senderName: 'RideLink Support',
        message:
            'This query has been marked as Resolved by Support. The conversation is now closed.',
        timestamp: now,
      ),
    );
    SupportService.instance.resolveSupportTicket(ticketId: ticketId);
    AppSnackBar.info(
      message: 'Query marked as Resolved and locked.',
    );
  }

  @override
  void onClose() {
    _supportTicketsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
}


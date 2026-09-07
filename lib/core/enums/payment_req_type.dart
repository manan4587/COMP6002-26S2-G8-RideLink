enum PaymentReqType { available, accepted, completed }

extension PaymentReqTypeExtension on PaymentReqType {
  String get title {
    switch (this) {
      case PaymentReqType.available:
        return 'Available Req.';
      case PaymentReqType.accepted:
        return 'Accepted Req.';
      case PaymentReqType.completed:
        return 'Completed Req.';
    }
  }
}

enum PaymentStatus { paymentCollected, bankDeposit, balance }

extension PaymentStatusExtension on PaymentStatus {
  String get title {
    switch (this) {
      case PaymentStatus.paymentCollected:
        return 'Payment Collected';
      case PaymentStatus.bankDeposit:
        return 'Bank Deposit';
      case PaymentStatus.balance:
        return 'Balance';
    }
  }
}
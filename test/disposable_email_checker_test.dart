import 'package:flutter_test/flutter_test.dart';
import 'package:ridelink/core/utils/disposable_email_checker.dart';
import 'package:ridelink/core/utils/validation_mixin.dart';

class _TestValidator with ValidationMixin {}

void main() {
  group('DisposableEmailChecker Tests', () {
    test('identifies popular disposable email domains when strict check is forced', () {
      final disposableEmails = [
        'user@10minutemail.com',
        'test@tempmail.com',
        'random@temp-mail.org',
        'john@guerrillamail.com',
        'user@sharklasers.com',
        'tester@mailinator.com',
        'fake@yopmail.com',
        'throwaway@throwawaymail.com',
        'temp@trashmail.com',
        'user@getnada.com',
        'anon@mohmal.com',
        'inbox@burnermail.io',
        'sample@emailondeck.com',
        'test@maildrop.cc',
        'user@subdomain.mailinator.com',
        'user@custom-tempmail-service.xyz',
      ];

      for (final email in disposableEmails) {
        expect(
          DisposableEmailChecker.isDisposable(email, bypassInDebug: false),
          isTrue,
          reason: 'Expected $email to be flagged as disposable',
        );
      }
    });

    test('permits legitimate email domains', () {
      final legitimateEmails = [
        'john.doe@gmail.com',
        'jane@googlemail.com',
        'user@outlook.com',
        'admin@hotmail.com',
        'student@university.edu.au',
        'employee@company.com.au',
        'driver@yahoo.com',
        'passenger@icloud.com',
        'support@proton.me',
        'contact@zoho.com',
      ];

      for (final email in legitimateEmails) {
        expect(
          DisposableEmailChecker.isDisposable(email, bypassInDebug: false),
          isFalse,
          reason: 'Expected $email to be allowed as legitimate',
        );
      }
    });

    test('bypasses disposable check in debug mode by default', () {
      // In flutter test / debug environment, default bypassInDebug is true
      expect(
        DisposableEmailChecker.isDisposable('test@mailinator.com'),
        isFalse,
      );
    });
  });

  group('ValidationMixin Email Tests', () {
    final validator = _TestValidator();

    test('validates format correctly', () {
      expect(validator.emailValidator(''), 'Please enter your email address');
      expect(validator.emailValidator(null), 'Please enter your email address');
      expect(validator.emailValidator('invalid-email'), 'Please enter a valid email address');
      expect(validator.emailValidator('user@gmail.com'), isNull);
    });
  });
}


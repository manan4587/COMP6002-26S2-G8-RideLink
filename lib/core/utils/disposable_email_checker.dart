import 'package:flutter/foundation.dart';

/// Utility to identify popular spam, disposable, and temporary email domains.
/// Prevents fraudulent or throwaway accounts from registering or logging in.
///
/// By default, in debug mode (`kDebugMode`), all validation checks are bypassed
/// so developers can test and develop without restriction. In production,
/// disposable email addresses are strictly blocked.
class DisposableEmailChecker {
  DisposableEmailChecker._();

  /// Master flag to enable or disable disposable email checks across the application.
  /// Set to `false` to disable checking in all modes (including release/production).
  /// Toggle this to `true` whenever you want to re-enable strict email blocking.
  static bool isEnabled = false;

  /// Known popular disposable, spam, and temporary email providers.
  static final Set<String> _disposableDomains = {
    // 10 Minute Mail variations
    '10minutemail.com',
    '10minutemail.net',
    '10minutemail.org',
    '10minmail.com',
    '10minutemail.co.uk',
    '10minutemail.de',
    '10minutemail.be',
    'minutemailbox.com',

    // TempMail variations
    'tempmail.com',
    'temp-mail.org',
    'tempmail.net',
    'temp-mail.io',
    'tempmail.ninja',
    'tempail.com',
    'temp-mail.com',
    'tempm.com',
    'tempmailo.com',
    'temp-mail.app',
    'mytemp.email',
    'mytempemail.com',
    'mytempmail.com',
    'tempinbox.com',

    // Guerrilla Mail variations
    'guerrillamail.com',
    'guerrillamail.net',
    'guerrillamail.biz',
    'guerrillamail.org',
    'guerrillamail.de',
    'guerrillamail.info',
    'guerrillamailblock.com',
    'sharklasers.com',
    'grr.la',
    'pokemail.net',
    'spam4.me',

    // Mailinator variations
    'mailinator.com',
    'mailin8r.com',
    'suremail.info',
    'spamherelots.com',
    'notmailinator.com',
    'mailinator2.com',
    'superrito.com',
    'binkmail.com',
    'bobmail.info',
    'safetymail.info',
    'trashymail.com',

    // Yopmail variations
    'yopmail.com',
    'yopmail.fr',
    'yopmail.net',
    'cool.fr.nf',
    'jetable.fr.nf',
    'nomail.xl.cx',
    'mega.zik.dj',
    'speed.1s.fr',
    'courriel.fr.nf',
    'moncourrier.fr.nf',
    'monemail.fr.nf',
    'monmail.fr.nf',
    'ypmail.com',

    // Trashmail & Throwaway variations
    'trashmail.com',
    'trashmail.net',
    'trashmail.me',
    'trashmail.org',
    'trash-mail.com',
    'trashcanmail.com',
    'throwawaymail.com',
    'throwaway.email',

    // Nada & Dropmail
    'getnada.com',
    'abcvg.com',
    'nada.ltd',
    'nada.email',
    'dropmail.me',

    // Mohmal
    'mohmal.com',
    'mohmal.in',
    'mohmal.im',

    // Other popular disposable & spam email providers
    'burnermail.io',
    'inboxkitten.com',
    'crazymailing.com',
    'dispostable.com',
    'fakemailgenerator.com',
    'emailondeck.com',
    'generator.email',
    'generator.co.ua',
    'maildrop.cc',
    'harakirimail.com',
    'internxt.com',
    'tmailor.com',
    'tempr.email',
    'discard.email',
    'discardmail.com',
    'spambox.us',
    'fakeinbox.com',
    'zippymail.info',
    'boximail.com',
    'meltmail.com',
    'mailcatch.com',
    'crazymail.com',
    'mailnesia.com',
    'fakemail.net',
    'emailfake.com',
    'getairmail.com',
    'disposablemail.com',
    'chacuo.net',
    'armyspy.com',
    'cuvox.de',
    'dayrep.com',
    'fleckens.hu',
    'gustr.com',
    'jourrapide.com',
    'rhyta.com',
    'teleworm.us',
    'tinemail.com',
    'mailnull.com',
    'spamex.com',
    'zoemail.org',
    '0-mail.com',
    '0815.ru',
    '0clickemail.com',
    '0w.ro',
    '0wnd.net',
    '0wnd.org',
    'inboxbear.com',
    'disposable.com',
    'luxusmail.org',
    'byom.de',
    'maildu.de',
    'spambog.com',
    'spambog.de',
    'spambog.ru',
    'trashmail.at',
    'wegwerfmail.de',
    'wegwerfmail.net',
    'wegwerfmail.org',
  };

  /// Characteristic keywords commonly found in temporary email provider domain names.
  static const List<String> _disposableKeywords = [
    'tempmail',
    'temp-mail',
    'disposable',
    'throwaway',
    'trashmail',
    'trash-mail',
    '10minute',
    '10minmail',
    'fakeinbox',
    'fakemail',
    'guerrillamail',
    'mailinator',
    'burnermail',
    'dropmail',
    'mohmal',
    'yopmail',
    'sharklasers',
    'getnada',
    'wegwerfmail',
  ];

  /// Checks whether an email belongs to a popular disposable or spam mail service.
  ///
  /// If [isEnabled] is `false`, this always returns `false` in all environments (release & debug).
  /// In debug mode (`kDebugMode`), this also returns `false` by default to allow
  /// unrestricted local development and testing. Pass [bypassInDebug] as `false`
  /// to force strict checking even in debug mode (e.g. for unit tests).
  static bool isDisposable(String? email, {bool bypassInDebug = true}) {
    if (email == null || email.trim().isEmpty) return false;

    // Master switch: if disabled, bypass checks everywhere (including release mode)
    if (!isEnabled) {
      return false;
    }

    // Allow all emails in debug mode unless explicitly forced
    if (bypassInDebug && kDebugMode) {
      return false;
    }

    final cleanEmail = email.trim().toLowerCase();
    final parts = cleanEmail.split('@');
    if (parts.length != 2) return false;

    final domain = parts[1].trim();
    if (domain.isEmpty) return false;

    // 1. Exact domain match
    if (_disposableDomains.contains(domain)) {
      return true;
    }

    // 2. Subdomain check (e.g., custom.mailinator.com)
    for (final disposableDomain in _disposableDomains) {
      if (domain.endsWith('.$disposableDomain')) {
        return true;
      }
    }

    // 3. Keyword check in domain name
    for (final keyword in _disposableKeywords) {
      if (domain.contains(keyword)) {
        return true;
      }
    }

    return false;
  }
}

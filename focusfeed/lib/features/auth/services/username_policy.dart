import 'package:profanity_filter/profanity_filter.dart';

class UsernamePolicy {
  static final RegExp _allowedPattern = RegExp(r'^[a-zA-Z0-9_]+$');
  static final RegExp _startsWithLetterPattern = RegExp(r'^[a-zA-Z]');
  static final ProfanityFilter _profanityFilter = ProfanityFilter();

  static const Set<String> _reservedTerms = {
    'admin',
    'administrator',
    'moderator',
    'support',
    'official',
    'focusfeed',
  };

  static String normalize(String username) => username.trim().toLowerCase();

  static String? validate(String? value) {
    final username = value?.trim() ?? '';
    final normalized = normalize(username);

    if (username.isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.length < 6 || username.length > 20) {
      return 'Username must be 6-20 characters';
    }
    if (!_startsWithLetterPattern.hasMatch(username)) {
      return 'Username must start with a letter';
    }
    if (!_allowedPattern.hasMatch(username)) {
      return 'Use only letters, numbers, and underscores';
    }
    if (username.contains('__')) {
      return 'Username cannot contain consecutive underscores';
    }
    if (username.endsWith('_')) {
      return 'Username cannot end with an underscore';
    }
    if (_reservedTerms.any(normalized.contains)) {
      return 'Please choose a different username';
    }
    if (_profanityFilter.hasProfanity(normalized)) {
      return 'Please choose a different username';
    }

    return null;
  }
}

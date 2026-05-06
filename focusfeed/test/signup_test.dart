import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:focusfeed/features/auth/services/username_policy.dart';
import 'package:focusfeed/features/auth/services/username_reservation_service.dart';
import 'package:profanity_filter/profanity_filter.dart';

void main() {
  group('UsernamePolicy', () {
    test('accepts and normalizes a valid username', () {
      expect(UsernamePolicy.validate('austyn_15'), isNull);
      expect(UsernamePolicy.normalize(' Austyn_15 '), 'austyn_15');
    });

    test('rejects common format problems', () {
      final invalidUsernames = [
        '',
        'short',
        '1austyn',
        'austyn!!',
        'austyn__15',
        'austyn_',
        'abcdefghijklmnopqrstu',
      ];

      for (final username in invalidUsernames) {
        expect(UsernamePolicy.validate(username), isNotNull);
      }
    });

    test('rejects reserved app/account words', () {
      expect(UsernamePolicy.validate('admin_user'), isNotNull);
      expect(UsernamePolicy.validate('FocusFeed7'), isNotNull);
      expect(UsernamePolicy.validate('support_15'), isNotNull);
    });

    test('rejects profanity through the shared filter package', () {
      final usernameSafePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9]{5,19}$');
      final filteredTerm = ProfanityFilter().wordsToFilterOutList.firstWhere(
        (term) => usernameSafePattern.hasMatch(term),
      );

      expect(UsernamePolicy.validate(filteredTerm), isNotNull);
    });
  });

  group('UsernameReservationService', () {
    test(
      'saves usernames to the reservation bank and rejects repeats',
      () async {
        final firestore = FakeFirebaseFirestore();
        final reservations = UsernameReservationService(firestore: firestore);

        await reservations.reserveUsername(uid: 'user-1', username: 'Austyn15');

        final savedUsername = await firestore
            .collection('usernames')
            .doc('austyn15')
            .get();
        expect(savedUsername.exists, isTrue);
        expect(savedUsername.data()?['uid'], 'user-1');

        expect(
          () =>
              reservations.reserveUsername(uid: 'user-2', username: 'austyn15'),
          throwsA(isA<UsernameTakenException>()),
        );
      },
    );
  });
}

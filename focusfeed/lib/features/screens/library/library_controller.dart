import 'package:focusfeed/features/screens/library/library_deck.dart';
import 'package:focusfeed/features/screens/library/library_repository.dart';

class LibraryController {
  final LibraryRepository repository;

  LibraryController({LibraryRepository? repository})
    : repository = repository ?? LibraryRepository();

  Stream<List<LibraryDeck>> streamDecks(String userId) {
    return repository.streamDecksForUser(userId);
  }
}

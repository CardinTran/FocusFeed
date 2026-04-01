import 'package:focusfeed/features/library/library_deck.dart';
import 'package:focusfeed/features/library/library_repository.dart';

class LibraryController {
  final LibraryRepository repository;

  LibraryController({LibraryRepository? repository})
    : repository = repository ?? LibraryRepository();

  Stream<List<LibraryDeck>> streamDecks(String userId) {
    return repository.streamDecksForUser(userId);
  }
}

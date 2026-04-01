import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusfeed/features/import/import_repository.dart';
import 'package:focusfeed/features/library/library_controller.dart';
import 'package:focusfeed/features/library/library_deck.dart';
import 'package:focusfeed/features/library/widgets/library_dialogs.dart';
import 'package:focusfeed/features/library/widgets/deck_grid.dart';
import 'package:focusfeed/features/library/widgets/library_empty_state.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryController _controller = LibraryController();
  final ImportRepository _importRepository = ImportRepository();

  Future<void> _openDeck(LibraryDeck deck) async {
    await showOpenDeckDialog(context, deck);
  }

  Future<void> _confirmDeleteDeck(LibraryDeck deck) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final shouldDelete = await showDeleteDeckDialog(context, deck);
    if (shouldDelete != true) return;

    await _importRepository.deleteImport(
      userId: user.uid,
      importId: deck.importId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F2A),
        body: SafeArea(
          child: Center(
            child: Text(
              'No authenticated user found.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Decks",
                    style: TextStyle(
                      color: Color.fromRGBO(133, 90, 251, 1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<List<LibraryDeck>>(
                  stream: _controller.streamDecks(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load decks: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final decks = snapshot.data ?? [];

                    if (decks.isEmpty) {
                      return const LibraryEmptyState();
                    }

                    return DeckGrid(
                      decks: decks,
                      onDeckTap: _openDeck,
                      onDeleteTap: _confirmDeleteDeck,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

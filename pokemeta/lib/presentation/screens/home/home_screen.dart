import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/models/tournament_model.dart';
import 'package:pokemeta/presentation/screens/cards/card_detail_screen.dart';
import 'package:pokemeta/presentation/screens/decks/active_deck_screen.dart';
import 'package:pokemeta/presentation/screens/tournaments/tournament_detail_screen.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/widgets/active_deck_banner.dart';
import 'package:pokemeta/widgets/pokemon_card_tile.dart';
import 'package:pokemeta/widgets/tournament_row_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFeed = 0;

  @override
  Widget build(BuildContext context) {
    // watch: Inicio se redibuja cuando cambia el mazo activo.
    final activeDeck = context.watch<ActiveDeckProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Buenas tardes, entrenador',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '¿Listo para tu próxima batalla?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        ActiveDeckBanner(
          currentCount: activeDeck.totalCards,
          maxCount: ActiveDeckProvider.maxCards,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ActiveDeckScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.emoji_events_outlined),
              label: Text('Torneos'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.menu_book_outlined),
              label: Text('Cartas'),
            ),
          ],
          selected: {_selectedFeed},
          onSelectionChanged: (selection) {
            setState(() => _selectedFeed = selection.first);
          },
        ),
        const SizedBox(height: 24),
        if (_selectedFeed == 0) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resultados recientes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Ver todos')),
            ],
          ),
          for (var i = 0; i < sampleTournaments.length; i++)
            TournamentRowCard(
              number: '${i + 1}'.padLeft(2, '0'),
              tournament: sampleTournaments[i],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => TournamentDetailScreen(
                      tournament: sampleTournaments[i],
                    ),
                  ),
                );
              },
            ),
        ] else ...[
          Text('Base de cartas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Buscar cartas',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              FilterChip(label: Text('Todas'), onSelected: null),
              FilterChip(label: Text('Pokémon'), onSelected: null),
              FilterChip(label: Text('Entrenador'), onSelected: null),
              FilterChip(label: Text('Energía'), onSelected: null),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.78,
            children: [
              for (final card in sampleCards)
                PokemonCardTile(
                  card: card,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => CardDetailScreen(card: card),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/models/tournament_model.dart';
import 'package:pokemeta/presentation/screens/cards/card_detail_screen.dart';
import 'package:pokemeta/presentation/screens/decks/active_deck_screen.dart';
import 'package:pokemeta/presentation/screens/tournaments/tournament_detail_screen.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/services/pokemon_tcg_service.dart';
import 'package:pokemeta/services/tournaments_service.dart';
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
  String _selectedType = 'Todas';
  final TextEditingController _searchController = TextEditingController();

  final PokemonTcgService _pokemonService = PokemonTcgService();
  final TournamentsService _tournamentsService = TournamentsService();

  late Future<List<TournamentModel>> _tournamentsFuture;
  late Future<List<CardModel>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = _tournamentsService.fetchRecentTournaments();
    _cardsFuture = _pokemonService.fetchCards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadTournaments() {
    setState(() {
      _tournamentsFuture = _tournamentsService.fetchRecentTournaments();
    });
  }

  void _reloadCards() {
    setState(() {
      _cardsFuture = _pokemonService.fetchCards(
        query: _searchController.text.trim(),
        type: _selectedType == 'Todas' ? null : _selectedType,
      );
    });
  }

  void _onTypeSelected(String type) {
    setState(() {
      _selectedType = type;
      _reloadCards();
    });
  }

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
          _buildTournamentsFeed(),
        ] else ...[
          _buildCardsFeed(),
        ],
      ],
    );
  }

  Widget _buildTournamentsFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Resultados recientes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: _reloadTournaments,
              child: const Text('Actualizar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Requisito 2: Consumo asíncrono con FutureBuilder
        FutureBuilder<List<TournamentModel>>(
          future: _tournamentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(
                message: 'No se pudieron cargar los torneos.',
                onRetry: _reloadTournaments,
              );
            }

            final tournaments = snapshot.data ?? [];
            if (tournaments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No hay torneos registrados recientemente.'),
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < tournaments.length; i++)
                  TournamentRowCard(
                    number: '${i + 1}'.padLeft(2, '0'),
                    tournament: tournaments[i],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => TournamentDetailScreen(
                            tournament: tournaments[i],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardsFeed() {
    final types = ['Todas', 'Fuego', 'Agua', 'Psíquico', 'Oscura', 'Incolora'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Base de cartas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Buscar cartas por nombre',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _reloadCards();
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _reloadCards(),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: types.map((type) {
              final isSelected = _selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) => _onTypeSelected(type),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Requisito 2: Consumo asíncrono con FutureBuilder
        FutureBuilder<List<CardModel>>(
          future: _cardsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Consultando API de Pokémon TCG...'),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(
                message: 'No se pudo conectar con la API de cartas.',
                onRetry: _reloadCards,
                onFallback: () {
                  setState(() {
                    _cardsFuture = Future.value(sampleCards);
                  });
                },
              );
            }

            final cards = snapshot.data ?? [];
            if (cards.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text('No se encontraron cartas con esos filtros.'),
                ),
              );
            }

            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.72,
              children: [
                for (final card in cards)
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
    VoidCallback? onFallback,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                if (onFallback != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onFallback,
                    child: const Text('Usar catálogo local'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

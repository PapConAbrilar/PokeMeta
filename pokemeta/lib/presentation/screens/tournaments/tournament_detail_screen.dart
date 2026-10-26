import 'package:flutter/material.dart';
import 'package:pokemeta/models/deck_model.dart';
import 'package:pokemeta/models/tournament_model.dart';
import 'package:pokemeta/presentation/screens/decks/deck_detail_screen.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:pokemeta/widgets/custom_stat_row.dart';
import 'package:provider/provider.dart';

/// Detalle de un torneo. Recibe el modelo por el constructor (req. 3).
///
/// Permite inspeccionar el mazo del ganador o de cualquier jugador del Top 8
/// y guardarlo directamente en la cuenta del usuario (Supabase + perfil).
class TournamentDetailScreen extends StatelessWidget {
  const TournamentDetailScreen({super.key, required this.tournament});

  final TournamentModel tournament;

  void _openTournamentDeck(BuildContext context, DeckModel deck) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            DeckDetailScreen(deck: deck, isTournamentDeck: true),
      ),
    );
  }

  Future<void> _saveDeckToProfile(BuildContext context, DeckModel deck) async {
    final decksProvider = context.read<DecksProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await decksProvider.add(deck);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Mazo "${deck.name}" guardado en Mis Mazos'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al guardar el mazo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final standings = tournament.standings;
    final winnerDeck = tournament.winnerDeckModel;

    return Scaffold(
      appBar: AppBar(title: Text(tournament.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${tournament.city} · ${tournament.date}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            tournament.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                CustomStatRow(
                  icon: Icons.location_on_outlined,
                  label: 'Modalidad / Sede',
                  value: tournament.city,
                ),
                const Divider(height: 1),
                CustomStatRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha',
                  value: tournament.date,
                ),
                const Divider(height: 1),
                CustomStatRow(
                  icon: Icons.groups_outlined,
                  label: 'Jugadores',
                  value: '${tournament.players}',
                ),
                const Divider(height: 1),
                CustomStatRow(
                  icon: Icons.emoji_events_outlined,
                  label: 'Mazo ganador',
                  value: tournament.winningDeck,
                ),
              ],
            ),
          ),
          if (winnerDeck != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _openTournamentDeck(context, winnerDeck),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Ver mazo ganador'),
                ),
                FilledButton.icon(
                  onPressed: () => _saveDeckToProfile(context, winnerDeck),
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Guardar mazo ganador'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Clasificación (Top 8)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (standings.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.leaderboard_outlined),
                title: Text('Sin posiciones por ahora'),
                subtitle: Text(
                  'Las posiciones del torneo aparecerán aquí cuando finalicen '
                  'las rondas en Limitless TCG.',
                ),
              ),
            )
          else
            for (final entry in standings)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: entry.placing == 1
                        ? Colors.amber.withValues(alpha: 0.25)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      '#${entry.placing}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: entry.placing == 1
                            ? Colors.amber.shade900
                            : null,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.country.isNotEmpty
                        ? '${entry.playerName} (${entry.country})'
                        : entry.playerName,
                  ),
                  subtitle: Text(
                    entry.hasDecklist
                        ? '${entry.deckName} · Ver mazo (${entry.toDeckModel(tournament.name).cardCount} cartas)'
                        : entry.deckName,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entry.record.isNotEmpty)
                        Chip(
                          label: Text(entry.record),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (entry.hasDecklist) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right),
                      ],
                    ],
                  ),
                  onTap: entry.hasDecklist
                      ? () => _openTournamentDeck(
                          context,
                          entry.toDeckModel(tournament.name),
                        )
                      : null,
                ),
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pokemeta/models/tournament_model.dart';
import 'package:pokemeta/widgets/custom_stat_row.dart';

/// Detalle de un torneo. Recibe el modelo por el constructor (req. 3).
class TournamentDetailScreen extends StatelessWidget {
  const TournamentDetailScreen({super.key, required this.tournament});

  final TournamentModel tournament;

  @override
  Widget build(BuildContext context) {
    final standings = tournament.standings;

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
                  subtitle: Text(entry.deckName),
                  trailing: entry.record.isNotEmpty
                      ? Chip(
                          label: Text(entry.record),
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
                ),
              ),
        ],
      ),
    );
  }
}

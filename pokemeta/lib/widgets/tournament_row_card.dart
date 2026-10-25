import 'package:flutter/material.dart';
import 'package:pokemeta/models/tournament_model.dart';

/// Fila de un torneo en la lista de resultados.
///
/// Recibe el modelo completo y arma los textos por dentro,
/// así quien la use no repite el formateo.
class TournamentRowCard extends StatelessWidget {
  const TournamentRowCard({
    super.key,
    required this.number,
    required this.tournament,
    this.onTap,
  });

  /// Posición en la lista, por ejemplo "01".
  final String number;
  final TournamentModel tournament;

  /// Opcional: si es null, la fila no reacciona al toque.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(number),
        title: Text(tournament.name),
        subtitle: Text(
          '${tournament.city} · ${tournament.date}\n${tournament.winningDeck}',
        ),
        isThreeLine: true,
        trailing: Text('${tournament.players} jugadores'),
        onTap: onTap,
      ),
    );
  }
}

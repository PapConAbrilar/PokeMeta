import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/widgets/card_image.dart';
import 'package:pokemeta/widgets/custom_stat_row.dart';
import 'package:provider/provider.dart';

/// Ahora es StatefulWidget porque guarda algo que cambia: si la carta
/// está marcada como favorita.
class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.card});

  final CardModel card;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  bool _isFavorite = false;
  double _starScale = 1.0;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      // Al subir la escala a 1.4, AnimatedScale anima el "latido".
      _starScale = 1.4;
    });
  }

  @override
  Widget build(BuildContext context) {
    // En el State, los datos del widget se leen con "widget.".
    final card = widget.card;
    // watch: la barra inferior se actualiza cuando cambia el mazo activo.
    final activeDeck = context.watch<ActiveDeckProvider>();
    final copies = activeDeck.copiesOf(card);
    final canAdd = activeDeck.canAdd(card);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            // AnimatedContainer: anima el cambio de color del fondo.
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isFavorite
                    ? Colors.amber.withValues(alpha: 0.25)
                    : Colors.transparent,
              ),
              child: IconButton(
                onPressed: _toggleFavorite,
                tooltip: _isFavorite
                    ? 'Quitar de favoritas'
                    : 'Marcar como favorita',
                // AnimatedScale: anima el tamaño de la estrella.
                icon: AnimatedScale(
                  scale: _starScale,
                  duration: const Duration(milliseconds: 150),
                  onEnd: () {
                    if (_starScale != 1.0) {
                      setState(() => _starScale = 1.0);
                    }
                  },
                  child: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    color: _isFavorite ? Colors.amber : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(card.cardNumber),
              ),
              const SizedBox(height: 8),
              Center(
                child: AspectRatio(
                  aspectRatio: 0.72,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CardImage(card: card, iconSize: 72),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${card.expansion} · ${card.rarity}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      card.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Text(
                    '${card.hp} HP',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const Divider(height: 32),
              Card(
                child: Column(
                  children: [
                    CustomStatRow(
                      icon: Icons.local_fire_department_outlined,
                      label: 'Tipo',
                      value: card.type,
                    ),
                    const Divider(height: 1),
                    CustomStatRow(
                      icon: Icons.shield_outlined,
                      label: 'Habilidad',
                      value: card.ability,
                    ),
                    const Divider(height: 1),
                    CustomStatRow(
                      icon: Icons.bolt_outlined,
                      label: 'Coste de retirada',
                      value: List.filled(card.retreatCost, '◯').join(' '),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flash_on_outlined),
                  title: Text(card.attack),
                  subtitle: Text(card.attackDescription),
                  trailing: Text(card.attackDamage),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Debilidad: ${card.weakness} · '
                  'Resistencia: ${card.resistance} · '
                  'Regulación: ${card.regulationMark}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('En el mazo activo'),
                Text('$copies ${copies == 1 ? 'copia' : 'copias'}'),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                // read: solo ejecuta una acción, no necesita observar.
                onPressed: canAdd
                    ? () => context.read<ActiveDeckProvider>().add(card)
                    : null,
                icon: const Icon(Icons.add),
                label: Text(
                  canAdd ? 'Agregar al mazo activo' : 'Límite alcanzado',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

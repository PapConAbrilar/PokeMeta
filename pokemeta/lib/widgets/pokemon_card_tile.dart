import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/widgets/card_image.dart';

/// Tarjeta de una carta para mostrar en la grilla del catálogo.
///
/// Incluye una animación implícita (`AnimatedScale`) de respuesta táctil
/// al presionar la tarjeta antes de iniciar el vuelo del `Hero`.
class PokemonCardTile extends StatefulWidget {
  const PokemonCardTile({super.key, required this.card, required this.onTap});

  final CardModel card;
  final VoidCallback onTap;

  @override
  State<PokemonCardTile> createState() => _PokemonCardTileState();
}

class _PokemonCardTileState extends State<PokemonCardTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: CardImage(card: card)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      card.expansion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/widgets/card_image.dart';

/// Tarjeta de una carta para mostrar en la grilla del catálogo.
///
/// No sabe NADA de navegación: solo dibuja la carta y avisa con [onTap]
/// cuando el usuario la toca. Quien la use decide qué pasa después.
class PokemonCardTile extends StatelessWidget {
  const PokemonCardTile({super.key, required this.card, required this.onTap});

  final CardModel card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(card.expansion),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

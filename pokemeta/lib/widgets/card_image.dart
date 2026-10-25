import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';

/// Imagen de una carta, con animación Hero incluida.
///
/// Hoy muestra un ícono de reemplazo. Cuando la API entregue la URL de la
/// imagen, solo hay que cambiar el contenido de este archivo.
///
/// El Hero usa como etiqueta (tag) el número de la carta: la grilla y el
/// detalle comparten la misma etiqueta, y por eso Flutter anima el vuelo
/// de una pantalla a la otra.
class CardImage extends StatelessWidget {
  const CardImage({super.key, required this.card, this.iconSize = 48});

  final CardModel card;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'card-image-${card.cardNumber}',
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          semanticLabel: 'Imagen de ${card.name} no disponible',
        ),
      ),
    );
  }
}

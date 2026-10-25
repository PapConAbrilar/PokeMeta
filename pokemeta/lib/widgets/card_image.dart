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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: card.imageUrl != null && card.imageUrl!.isNotEmpty
            ? Image.network(
                card.imageUrl!,
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _placeholder(
                    context,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _placeholder(context);
                },
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context, {Widget? child}) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: child ??
          Icon(
            Icons.image_outlined,
            size: iconSize,
            semanticLabel: 'Imagen de ${card.name} no disponible',
          ),
    );
  }
}

import 'package:flutter/material.dart';

/// Muestra un número destacado con su etiqueta debajo.
/// Ejemplo: "42" / "Cartas".
class StatBadgeWidget extends StatelessWidget {
  const StatBadgeWidget({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

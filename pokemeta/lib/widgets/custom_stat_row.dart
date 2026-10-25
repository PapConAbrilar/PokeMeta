import 'package:flutter/material.dart';

/// Fila de una característica: icono a la izquierda, nombre y valor a la derecha.
/// Se usa en el detalle de carta (Tipo, Habilidad, Coste de retirada).
class CustomStatRow extends StatelessWidget {
  const CustomStatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value),
    );
  }
}

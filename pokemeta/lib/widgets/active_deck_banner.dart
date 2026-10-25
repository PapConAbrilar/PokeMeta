import 'package:flutter/material.dart';

/// Resumen del mazo que el usuario está construyendo.
///
/// No conoce el Provider: recibe los números por constructor y avisa con
/// [onTap]. El progreso se calcula aquí para no desincronizarse del texto.
class ActiveDeckBanner extends StatelessWidget {
  const ActiveDeckBanner({
    super.key,
    required this.currentCount,
    this.maxCount = 60,
    this.onTap,
  });

  final int currentCount;
  final int maxCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.style_outlined),
        title: const Text('Constructor de mazo activo'),
        subtitle: Text('$currentCount de $maxCount cartas'),
        trailing: CircularProgressIndicator(value: currentCount / maxCount),
        onTap: onTap,
      ),
    );
  }
}

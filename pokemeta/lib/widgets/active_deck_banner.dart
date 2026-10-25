import 'package:flutter/material.dart';

/// Resumen del mazo que el usuario está construyendo.
///
/// No conoce el Provider: recibe los números por constructor y avisa con
/// [onTap]. Incluye animaciones implícitas (`AnimatedContainer`,
/// `AnimatedSwitcher` y `TweenAnimationBuilder`) para reflejar el progreso.
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
    final colorScheme = Theme.of(context).colorScheme;
    final hasCards = currentCount > 0;
    final progress = (currentCount / maxCount).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: hasCards
            ? colorScheme.primaryContainer.withValues(alpha: 0.45)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasCards
              ? colorScheme.primary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            hasCards ? Icons.style : Icons.style_outlined,
            color: hasCards ? colorScheme.primary : null,
          ),
          title: const Text('Constructor de mazo activo'),
          subtitle: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.centerLeft,
              children: [
                ...previousChildren,
                ?currentChild,
              ],
            ),
            child: Text(
              '$currentCount de $maxCount cartas',
              key: ValueKey<int>(currentCount),
            ),
          ),
          trailing: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return CircularProgressIndicator(value: animatedValue);
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

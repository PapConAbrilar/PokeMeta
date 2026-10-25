import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/widgets/card_image.dart';

/// Visor interactivo 3D estilo Pokémon TCG Pocket.
///
/// Permite inclinar la carta en los ejes X e Y arrastrando el dedo,
/// proyecta una sombra dinámica y dibuja un reflejo holográfico (*holo glare*)
/// que reacciona al ángulo de inclinación. Al soltar, regresa con rebote suave.
class Interactive3dCard extends StatefulWidget {
  const Interactive3dCard({super.key, required this.card});

  final CardModel card;

  @override
  State<Interactive3dCard> createState() => _Interactive3dCardState();
}

class _Interactive3dCardState extends State<Interactive3dCard> {
  /// Inclinación normalizada en rango [-1.0, 1.0] para (dx, dy).
  Offset _targetTilt = Offset.zero;
  bool _isDragging = false;

  static const double _maxAngle = 0.42; // ~24 grados de inclinación máxima

  void _updateTilt(Offset localPosition, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final dx = ((localPosition.dx - centerX) / centerX).clamp(-1.0, 1.0);
    final dy = ((localPosition.dy - centerY) / centerY).clamp(-1.0, 1.0);

    setState(() {
      _isDragging = true;
      _targetTilt = Offset(dx, dy);
    });
  }

  void _resetTilt() {
    setState(() {
      _isDragging = false;
      _targetTilt = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            final box = context.findRenderObject() as RenderBox?;
            if (box != null) {
              _updateTilt(details.localPosition, box.size);
            }
          },
          onPanUpdate: (details) {
            final box = context.findRenderObject() as RenderBox?;
            if (box != null) {
              _updateTilt(details.localPosition, box.size);
            }
          },
          onPanEnd: (_) => _resetTilt(),
          onPanCancel: _resetTilt,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(begin: Offset.zero, end: _targetTilt),
            duration: _isDragging
                ? const Duration(milliseconds: 40)
                : const Duration(milliseconds: 550),
            curve: _isDragging ? Curves.linear : Curves.easeOutBack,
            builder: (context, tilt, child) {
              final rotateX = -tilt.dy * _maxAngle;
              final rotateY = tilt.dx * _maxAngle;
              final tiltIntensity = tilt.distance.clamp(0.0, 1.0);
              final scale = 1.0 + (tiltIntensity * 0.04);

              final matrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0014) // Perspectiva 3D de cámara
                .. scaleByDouble(scale, scale, 1.0, 1.0)
                ..rotateX(rotateX)
                ..rotateY(rotateY);

              return Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.22 + (tiltIntensity * 0.16),
                        ),
                        blurRadius: 18 + (tiltIntensity * 14),
                        spreadRadius: 1,
                        offset: Offset(-tilt.dx * 18, -tilt.dy * 18 + 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        child!,
                        // Capa de brillo holográfico e iluminación especular
                        if (tiltIntensity > 0.01)
                          IgnorePointer(
                            child: Opacity(
                              opacity: (tiltIntensity * 0.55).clamp(0.0, 0.65),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(
                                      -tilt.dx * 1.6,
                                      -tilt.dy * 1.6,
                                    ),
                                    end: Alignment(
                                      tilt.dx * 1.6,
                                      tilt.dy * 1.6,
                                    ),
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.cyanAccent.withValues(alpha: 0.35),
                                      Colors.white.withValues(alpha: 0.7),
                                      Colors.purpleAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                      Colors.amberAccent.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                    stops: const [
                                      0.0,
                                      0.3,
                                      0.5,
                                      0.68,
                                      0.85,
                                      1.0,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: CardImage(card: widget.card, iconSize: 72),
          ),
        );
      },
    );
  }
}


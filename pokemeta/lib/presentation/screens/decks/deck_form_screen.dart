import 'package:flutter/material.dart';
import 'package:pokemeta/models/deck_model.dart';

/// Formulario para crear o editar un mazo.
///
/// - Si [deck] es null, crea un mazo nuevo.
/// - Si [deck] trae un mazo, edita ese mazo (el formulario parte con sus datos).
///
/// Al guardar, devuelve el [DeckModel] resultante a la pantalla anterior
/// con Navigator.pop. Si el usuario vuelve atrás, devuelve null.
class DeckFormScreen extends StatefulWidget {
  const DeckFormScreen({super.key, this.deck});

  final DeckModel? deck;

  @override
  State<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends State<DeckFormScreen> {
  /// La llave identifica al formulario y permite validarlo completo.
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _format;

  static const _formats = ['Estándar', 'Expandido'];

  bool get _isEditing => widget.deck != null;

  @override
  void initState() {
    super.initState();
    final deck = widget.deck;
    _nameController = TextEditingController(text: deck?.name ?? '');
    _descriptionController = TextEditingController(
      text: deck?.description ?? '',
    );
    _format = deck?.format;
  }

  @override
  void dispose() {
    // Los controladores hay que liberarlos para no dejar memoria ocupada.
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Un validator devuelve un texto con el error, o null si el valor es válido.
  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Escribe un nombre para el mazo';
    if (text.length < 3) return 'El nombre debe tener al menos 3 caracteres';
    if (text.length > 30) return 'El nombre no puede superar los 30 caracteres';
    return null;
  }

  String? _validateFormat(String? value) {
    if (value == null) return 'Elige un formato de juego';
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Describe brevemente la estrategia del mazo';
    if (text.length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    if (text.length > 200) {
      return 'La descripción no puede superar los 200 caracteres';
    }
    return null;
  }

  void _submit() {
    // validate() ejecuta todos los validator y muestra los errores.
    // Devuelve true solo si todos los campos son válidos.
    if (!_formKey.currentState!.validate()) return;

    final result = DeckModel(
      name: _nameController.text.trim(),
      format: _format!,
      description: _descriptionController.text.trim(),
      // Al editar se conservan las cartas; un mazo nuevo parte vacío.
      cards: widget.deck?.cards ?? const [],
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar mazo' : 'Nuevo mazo')),
      body: Form(
        key: _formKey,
        // Muestra los errores apenas el usuario toca un campo.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              validator: _validateName,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del mazo',
                hintText: 'Ej. Infernal Reign',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _format,
              validator: _validateFormat,
              // Al cambiar la opción, guardamos el valor para usarlo al enviar.
              onChanged: (value) => _format = value,
              decoration: const InputDecoration(
                labelText: 'Formato de juego',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final format in _formats)
                  DropdownMenuItem(value: format, child: Text(format)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              validator: _validateDescription,
              minLines: 3,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Cuenta cómo juega este mazo',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Guardar cambios' : 'Crear mazo'),
            ),
          ],
        ),
      ),
    );
  }
}

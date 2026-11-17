import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/lugar.dart';
import '../theme/fet_theme.dart';

/// Ventana para ponerle nombre y categoría a un punto nuevo.
/// Devuelve el Lugar con Navigator.pop, o null si se cancela.
class DialogoLugar extends StatefulWidget {
  const DialogoLugar({super.key, required this.punto});

  final LatLng punto;

  @override
  State<DialogoLugar> createState() => _DialogoLugarState();
}

class _DialogoLugarState extends State<DialogoLugar> {
  final _nombreCtrl = TextEditingController();
  CategoriaLugar _categoria = CategoriaLugar.salon;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.length < 2) {
      setState(() => _error = 'Escribe un nombre');
      return;
    }
    Navigator.of(context).pop(
      Lugar(
        id: '', // Firestore le asigna el id al guardarlo
        nombre: nombre,
        categoria: _categoria,
        punto: widget.punto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.punto.latitude.toStringAsFixed(5);
    final lng = widget.punto.longitude.toStringAsFixed(5);

    return AlertDialog(
      title: const Text('Nuevo punto'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coordenadas: $lat, $lng',
                style: const TextStyle(color: FetColors.gris, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nombreCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nombre del lugar',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _guardar(),
              ),
              const SizedBox(height: 16),
              const Text('Categoría'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoriaLugar.values
                    .map(
                      (c) => ChoiceChip(
                        avatar: Icon(c.icono, size: 18, color: c.color),
                        label: Text(c.etiqueta),
                        selected: _categoria == c,
                        onSelected: (_) => setState(() => _categoria = c),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

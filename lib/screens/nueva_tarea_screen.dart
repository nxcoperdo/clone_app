import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../theme/fet_theme.dart';

/// Formulario para crear una tarea. Al guardar, DEVUELVE la tarea
/// a la pantalla anterior con Navigator.pop(context, tarea).
class NuevaTareaScreen extends StatefulWidget {
  const NuevaTareaScreen({super.key});

  @override
  State<NuevaTareaScreen> createState() => _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _materiaCtrl = TextEditingController();
  Prioridad _prioridad = Prioridad.media;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _materiaCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final nueva = Tarea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text.trim(),
      materia: _materiaCtrl.text.trim(),
      prioridad: _prioridad,
    );
    Navigator.of(context).pop(nueva); // devuelve la tarea
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva tarea'),
        backgroundColor: FetColors.verde,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
                prefixIcon: Icon(Icons.edit_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().length < 3) {
                  return 'Escribe al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _materiaCtrl,
              decoration: const InputDecoration(
                labelText: 'Materia',
                prefixIcon: Icon(Icons.menu_book_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Escribe la materia';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Prioridad', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<Prioridad>(
              segments: Prioridad.values
                  .map(
                    (p) => ButtonSegment<Prioridad>(
                      value: p,
                      label: Text(p.etiqueta),
                    ),
                  )
                  .toList(),
              selected: {_prioridad},
              onSelectionChanged: (seleccion) {
                setState(() => _prioridad = seleccion.first);
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar tarea'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../theme/fet_theme.dart';
import '../widgets/codigo_paso.dart';

/// Recibe una tarea por el CONSTRUCTOR, permite editarla
/// y devuelve la versión modificada al guardar.
class DetalleTareaScreen extends StatefulWidget {
  const DetalleTareaScreen({super.key, required this.tarea});

  final Tarea tarea;

  @override
  State<DetalleTareaScreen> createState() => _DetalleTareaScreenState();
}

class _DetalleTareaScreenState extends State<DetalleTareaScreen> {
  late Prioridad _prioridad;
  late bool _completada;

  @override
  void initState() {
    super.initState();
    // "widget" da acceso a los datos que llegaron por el constructor
    _prioridad = widget.tarea.prioridad;
    _completada = widget.tarea.completada;
  }

  void _guardar() {
    final editada = widget.tarea.copyWith(
      prioridad: _prioridad,
      completada: _completada,
    );
    Navigator.of(context).pop(editada);
  }

  @override
  Widget build(BuildContext context) {
    final tarea = widget.tarea;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la tarea'),
        backgroundColor: FetColors.verde,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FetColors.verde,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarea.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tarea.materia,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tarea completada'),
            value: _completada,
            onChanged: (valor) => setState(() => _completada = valor),
          ),
          const SizedBox(height: 8),
          Center(
            child: CodigoPaso(
              paso: 'paso 5',
              clave: 'paso5-${tarea.titulo.toUpperCase()}',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.check),
            label: const Text('Guardar cambios'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ),
    );
  }
}

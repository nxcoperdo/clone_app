import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../theme/fet_theme.dart';
import '../widgets/codigo_paso.dart';
import '../widgets/etiqueta_prioridad.dart';
import 'detalle_tarea_screen.dart'; // NUEVO
import 'nueva_tarea_screen.dart'; // NUEVO

class TareasTab extends StatelessWidget {
  const TareasTab({
    super.key,
    required this.tareas,
    required this.onAlternar,
    required this.onEliminar,
    required this.onAgregar,
    required this.onActualizar,
  });

  final List<Tarea> tareas;
  final ValueChanged<Tarea> onAlternar;
  final ValueChanged<Tarea> onEliminar;
  final ValueChanged<Tarea> onAgregar; // NUEVO
  final ValueChanged<Tarea> onActualizar; // NUEVO

  // NUEVO: abre el formulario y ESPERA (await) la tarea que devuelve
  Future<void> _abrirNuevaTarea(BuildContext context) async {
    final nueva = await Navigator.of(context).push<Tarea>(
      MaterialPageRoute(builder: (_) => const NuevaTareaScreen()),
    );
    if (nueva != null) {
      onAgregar(nueva);
    }
  }

  // NUEVO: envía la tarea al detalle y recibe la versión editada
  Future<void> _abrirDetalle(BuildContext context, Tarea tarea) async {
    final editada = await Navigator.of(context).push<Tarea>(
      MaterialPageRoute(builder: (_) => DetalleTareaScreen(tarea: tarea)),
    );
    if (editada != null) {
      onActualizar(editada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completadas = tareas.where((t) => t.completada).length;

    return Column(
      children: [
        _Encabezado(
          completadas: completadas,
          total: tareas.length,
          onNueva: () => _abrirNuevaTarea(context), // NUEVO
        ),
        Expanded(
          child: tareas.isEmpty
              ? const Center(child: Text('No tienes tareas pendientes.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: tareas.length,
                  itemBuilder: (context, i) {
                    final tarea = tareas[i];
                    return Dismissible(
                      key: ValueKey(tarea.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) {
                        final mensajero = ScaffoldMessenger.of(context);
                        onEliminar(tarea);
                        mensajero.showSnackBar(
                          SnackBar(
                            content: Text('Eliminaste "${tarea.titulo}"'),
                          ),
                        );
                      },
                      child: _TarjetaTarea(
                        tarea: tarea,
                        onAlternar: () => onAlternar(tarea),
                        onAbrir: () => _abrirDetalle(context, tarea), // NUEVO
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.completadas,
    required this.total,
    required this.onNueva,
  });

  final int completadas;
  final int total;
  final VoidCallback onNueva; // NUEVO

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: FetColors.verdeClaro,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completadas de $total completadas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FetColors.verdeOscuro,
                  ),
                ),
              ),
              // NUEVO: botón para crear tareas
              FilledButton.icon(
                onPressed: onNueva,
                icon: const Icon(Icons.add),
                label: const Text('Nueva'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca una tarea para ver su detalle. Usa la casilla para marcarla.',
          ),
          CodigoPaso(paso: 'paso 4', clave: 'paso4-$completadas-$total'),
        ],
      ),
    );
  }
}

class _TarjetaTarea extends StatelessWidget {
  const _TarjetaTarea({
    required this.tarea,
    required this.onAlternar,
    required this.onAbrir,
  });

  final Tarea tarea;
  final VoidCallback onAlternar;
  final VoidCallback onAbrir; // NUEVO

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onAbrir, // NUEVO: ahora tocar abre el detalle
        leading: Checkbox(
          value: tarea.completada,
          onChanged: (_) => onAlternar(),
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            decoration: tarea.completada ? TextDecoration.lineThrough : null,
            color: tarea.completada ? Colors.grey : null,
          ),
        ),
        subtitle: Text(tarea.materia),
        trailing: EtiquetaPrioridad(prioridad: tarea.prioridad),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../config/estudiante.dart';
import '../models/tarea.dart';
import '../theme/fet_theme.dart';

/// Tablero de inicio: todo se CALCULA a partir de la lista de tareas.
class InicioTab extends StatelessWidget {
  const InicioTab({super.key, required this.tareas});

  final List<Tarea> tareas;

  @override
  Widget build(BuildContext context) {
    final total = tareas.length;
    final completadas = tareas.where((t) => t.completada).length;
    final pendientes = total - completadas;
    final urgentes = tareas
        .where((t) => !t.completada && t.prioridad == Prioridad.alta)
        .length;
    final avance = total == 0 ? 0.0 : completadas / total;
    final proximas = tareas.where((t) => !t.completada).take(3).toList();
    final nombreFirebase = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final nombre =
        nombreFirebase.isNotEmpty ? nombreFirebase : kNombreEstudiante;
    final primerNombre = nombre.trim().split(' ').first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tarjeta verde con el avance
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
                'Hola, $primerNombre',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Este es tu avance del semestre',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: avance,
                  minHeight: 10,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(avance * 100).round()}% completado',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tres indicadores
        Row(
          children: [
            Expanded(
              child: _Indicador(
                icono: Icons.hourglass_empty,
                valor: pendientes,
                texto: 'Pendientes',
                color: FetColors.verde,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Indicador(
                icono: Icons.check_circle_outline,
                valor: completadas,
                texto: 'Hechas',
                color: FetColors.verdeOscuro,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Indicador(
                icono: Icons.priority_high,
                valor: urgentes,
                texto: 'Urgentes',
                color: Prioridad.alta.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Próximas tareas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (proximas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No tienes tareas pendientes. ¡Bien hecho!'),
          )
        else
          ...proximas.map(
            (t) => Card(
              child: ListTile(
                leading: Icon(Icons.circle, size: 14, color: t.prioridad.color),
                title: Text(t.titulo),
                subtitle: Text(t.materia),
              ),
            ),
          ),
      ],
    );
  }
}

/// Recuadro pequeño con un número y un texto.
class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icono,
    required this.valor,
    required this.texto,
    required this.color,
  });

  final IconData icono;
  final int valor;
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FetColors.verdeClaro, width: 2),
      ),
      child: Column(
        children: [
          Icon(icono, color: color),
          const SizedBox(height: 6),
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(texto, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

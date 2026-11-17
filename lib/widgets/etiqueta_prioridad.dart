import 'package:flutter/material.dart';

import '../models/tarea.dart';

/// Pequeña etiqueta de color con la prioridad (Alta, Media, Baja).
class EtiquetaPrioridad extends StatelessWidget {
  const EtiquetaPrioridad({super.key, required this.prioridad});

  final Prioridad prioridad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: prioridad.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        prioridad.etiqueta,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

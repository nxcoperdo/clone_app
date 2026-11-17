import 'package:flutter/material.dart';

/// Prioridad de una tarea. Es un "enum mejorado": cada valor
/// guarda su propio texto y su propio color.
enum Prioridad {
  alta('Alta', Color(0xFFC62828)),
  media('Media', Color(0xFFE08A00)),
  baja('Baja', Color(0xFF546E7A));

  const Prioridad(this.etiqueta, this.color);

  final String etiqueta;
  final Color color;
}

/// Modelo de datos: representa UNA tarea del estudiante.
class Tarea {
  const Tarea({
    required this.id,
    required this.titulo,
    required this.materia,
    this.prioridad = Prioridad.media,
    this.completada = false,
  });

  final String id;
  final String titulo;
  final String materia;
  final Prioridad prioridad;
  final bool completada;

  /// Crea una COPIA de la tarea cambiando solo lo que le pases.
  Tarea copyWith({
    String? titulo,
    String? materia,
    Prioridad? prioridad,
    bool? completada,
  }) {
    return Tarea(
      id: id,
      titulo: titulo ?? this.titulo,
      materia: materia ?? this.materia,
      prioridad: prioridad ?? this.prioridad,
      completada: completada ?? this.completada,
    );
  }

  // NUEVO: convierte la tarea en un mapa para guardarla en Firestore.
  // El id no se guarda adentro: es el nombre del documento.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'materia': materia,
      'prioridad': prioridad.name, // se guarda como texto: 'alta', 'media'...
      'completada': completada,
    };
  }

  // NUEVO: crea una tarea a partir de un documento de Firestore.
  factory Tarea.fromMap(String id, Map<String, dynamic> datos) {
    return Tarea(
      id: id,
      titulo: datos['titulo'] as String? ?? '',
      materia: datos['materia'] as String? ?? '',
      prioridad: Prioridad.values.firstWhere(
        (p) => p.name == datos['prioridad'],
        orElse: () => Prioridad.media,
      ),
      completada: datos['completada'] as bool? ?? false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Tipo de lugar: cada uno con su texto, ícono y color.
enum CategoriaLugar {
  salon('Salón', Icons.school, Color(0xFFF40009)),
  comida('Comida', Icons.restaurant, Color(0xFFE08A00)),
  deporte('Deporte', Icons.sports_soccer, Color(0xFF1565C0)),
  otro('Otro', Icons.place, Color(0xFF6A1B9A));

  const CategoriaLugar(this.etiqueta, this.icono, this.color);

  final String etiqueta;
  final IconData icono;
  final Color color;
}

/// Un punto marcado en el mapa.
class Lugar {
  const Lugar({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.punto,
  });

  final String id;
  final String nombre;
  final CategoriaLugar categoria;
  final LatLng punto;

  /// Firestore no entiende LatLng: guardamos latitud y longitud por separado.
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria.name,
      'lat': punto.latitude,
      'lng': punto.longitude,
    };
  }

  factory Lugar.fromMap(String id, Map<String, dynamic> datos) {
    return Lugar(
      id: id,
      nombre: datos['nombre'] as String? ?? '',
      categoria: CategoriaLugar.values.firstWhere(
        (c) => c.name == datos['categoria'],
        orElse: () => CategoriaLugar.otro,
      ),
      punto: LatLng(
        (datos['lat'] as num? ?? 0).toDouble(),
        (datos['lng'] as num? ?? 0).toDouble(),
      ),
    );
  }
}

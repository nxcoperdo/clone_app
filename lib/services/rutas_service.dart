import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Resultado de calcular un recorrido.
class Ruta {
  const Ruta({
    required this.puntos,
    required this.distanciaMetros,
    required this.duracionSegundos,
    required this.porCalles,
  });

  final List<LatLng> puntos; // la línea que se dibuja en el mapa
  final double distanciaMetros;
  final double duracionSegundos;
  final bool porCalles; // false = línea recta de respaldo
}

/// Pide el recorrido a pie a un servidor público de OSRM (OpenStreetMap).
class RutasService {
  static const _servidor =
      'https://routing.openstreetmap.de/routed-foot/route/v1/foot';

  Future<Ruta> calcular(LatLng origen, LatLng destino) async {
    // OSRM recibe primero la LONGITUD y después la LATITUD
    final url = Uri.parse(
      '$_servidor/'
      '${origen.longitude},${origen.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final respuesta =
          await http.get(url).timeout(const Duration(seconds: 12));
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
        final rutas = datos['routes'] as List<dynamic>;
        if (rutas.isNotEmpty) {
          final ruta = rutas.first as Map<String, dynamic>;
          final geometria = ruta['geometry'] as Map<String, dynamic>;
          final coordenadas = geometria['coordinates'] as List<dynamic>;
          final puntos = coordenadas.map((c) {
            final par = c as List<dynamic>;
            return LatLng(
              (par[1] as num).toDouble(),
              (par[0] as num).toDouble(),
            );
          }).toList();
          return Ruta(
            puntos: puntos,
            distanciaMetros: (ruta['distance'] as num).toDouble(),
            duracionSegundos: (ruta['duration'] as num).toDouble(),
            porCalles: true,
          );
        }
      }
    } catch (_) {
      // Sin internet, servidor ocupado o bloqueado: usamos el plan B.
    }

    // Plan B: línea recta, caminando a 1.3 m/s (unos 4.7 km/h)
    final metros =
        const Distance().as(LengthUnit.Meter, origen, destino).toDouble();
    return Ruta(
      puntos: [origen, destino],
      distanciaMetros: metros,
      duracionSegundos: metros / 1.3,
      porCalles: false,
    );
  }
}

/// Convierte segundos a "8 min" o "1 h 15 min".
String formatoDuracion(double segundos) {
  final minutos = (segundos / 60).ceil();
  if (minutos < 60) {
    return '$minutos min';
  }
  return '${minutos ~/ 60} h ${minutos % 60} min';
}

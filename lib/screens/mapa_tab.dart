import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../config/mapa_config.dart';
import '../models/lugar.dart';
import '../services/lugares_service.dart';
import '../services/rutas_service.dart'; // NUEVO
import '../services/ubicacion_service.dart';
import '../theme/fet_theme.dart';
import '../widgets/dialogo_lugar.dart';

/// Pestaña Mapa (versión final): ubicación, puntos marcados y cómo llegar.
class MapaTab extends StatefulWidget {
  const MapaTab({super.key});

  @override
  State<MapaTab> createState() => _MapaTabState();
}

class _MapaTabState extends State<MapaTab> {
  final _mapa = MapController();
  final _ubicacion = UbicacionService();
  final _rutas = RutasService(); // NUEVO
  late final LugaresService _lugaresService;

  StreamSubscription<Position>? _subPosicion;
  StreamSubscription<List<Lugar>>? _subLugares;

  LatLng? _yo;
  double _precision = 0;
  bool _buscando = false;
  List<Lugar> _lugares = [];

  Lugar? _destino; // NUEVO: a dónde vamos
  Ruta? _ruta; // NUEVO: el recorrido calculado
  bool _calculando = false; // NUEVO
  bool _llego = false; // NUEVO

  @override
  void initState() {
    super.initState();
    _lugaresService = LugaresService(FirebaseAuth.instance.currentUser!.uid);
    _subLugares = _lugaresService.flujo().listen(
      (lista) {
        if (mounted) {
          setState(() => _lugares = lista);
        }
      },
      onError: (Object e) => _mensaje('No se pudieron leer los puntos: $e'),
    );
  }

  @override
  void dispose() {
    _subPosicion?.cancel();
    _subLugares?.cancel();
    super.dispose();
  }

  void _mensaje(String texto, {bool error = true, SnackBarAction? accion}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : FetColors.verde,
        action: accion,
        duration: Duration(seconds: accion == null ? 4 : 8),
      ),
    );
  }

  // ---------- Ubicación ----------

  Future<void> _activarUbicacion() async {
    setState(() => _buscando = true);
    try {
      final posicion = await _ubicacion.posicionActual();
      if (!mounted) return;
      _actualizarPosicion(posicion);
      _mapa.move(_yo!, 17);
      _subPosicion ??= _ubicacion.seguirPosicion().listen(
        _actualizarPosicion,
        onError: (Object e) => _mensaje('Se perdió la ubicación: $e'),
      );
    } on UbicacionException catch (e) {
      // Si hay un ajuste que lo soluciona, el mensaje trae un botón para abrirlo
      final accion = e.accion == AccionUbicacion.ninguna
          ? null
          : SnackBarAction(
              label: 'Abrir ajustes',
              textColor: Colors.white,
              onPressed: () => _ubicacion.abrirAjustes(e.accion),
            );
      _mensaje(e.mensaje, accion: accion);
    } on TimeoutException {
      _mensaje(
        'No llegó la ubicación. En el emulador fíjala en Extended Controls → '
        'Location; en el teléfono acércate a una ventana o sal al aire libre.',
      );
    } catch (e) {
      _mensaje('No se pudo obtener la ubicación: $e');
    } finally {
      if (mounted) {
        setState(() => _buscando = false);
      }
    }
  }

  void _actualizarPosicion(Position posicion) {
    if (!mounted) return;
    setState(() {
      _yo = LatLng(posicion.latitude, posicion.longitude);
      _precision = posicion.accuracy;
    });
    _revisarLlegada(); // NUEVO
  }

  void _botonUbicacion() {
    final yo = _yo;
    if (yo != null) {
      _mapa.move(yo, 17);
    } else {
      _activarUbicacion();
    }
  }

  // ---------- Puntos marcados ----------

  Future<void> _nuevoLugar(LatLng punto) async {
    final lugar = await showDialog<Lugar>(
      context: context,
      builder: (_) => DialogoLugar(punto: punto),
    );
    if (lugar == null) return;
    try {
      await _lugaresService.agregar(lugar);
      _mensaje('Guardaste "${lugar.nombre}"', error: false);
    } catch (e) {
      _mensaje('No se pudo guardar: $e');
    }
  }

  Future<void> _eliminar(Lugar lugar) async {
    if (_destino?.id == lugar.id) {
      _terminarRuta();
    }
    try {
      await _lugaresService.eliminar(lugar.id);
    } catch (e) {
      _mensaje('No se pudo eliminar: $e');
    }
  }

  void _verLugar(Lugar lugar) {
    final yo = _yo;
    final distancia =
        yo == null ? null : UbicacionService.distanciaMetros(yo, lugar.punto);
    final lat = lugar.punto.latitude.toStringAsFixed(5);
    final lng = lugar.punto.longitude.toStringAsFixed(5);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(lugar.categoria.icono, color: lugar.categoria.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lugar.nombre,
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${lugar.categoria.etiqueta} · $lat, $lng'),
            if (distancia != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Está a ${formatoDistancia(distancia)} de ti en línea recta',
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                // NUEVO: botón para trazar la ruta
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _irA(lugar);
                    },
                    icon: const Icon(Icons.directions_walk),
                    label: const Text('Cómo llegar'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _eliminar(lugar);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Cómo llegar (NUEVO) ----------

  Future<void> _irA(Lugar lugar) async {
    // Sin tu ubicación no hay punto de partida
    if (_yo == null) {
      await _activarUbicacion();
      if (_yo == null) return;
    }
    if (!mounted) return;
    setState(() {
      _destino = lugar;
      _ruta = null;
      _calculando = true;
      _llego = false;
    });

    final ruta = await _rutas.calcular(_yo!, lugar.punto);
    // Si el usuario canceló mientras calculábamos, no hacemos nada
    if (!mounted || _destino?.id != lugar.id) return;
    setState(() {
      _ruta = ruta;
      _calculando = false;
    });

    // Encuadra el mapa para que se vea toda la ruta
    _mapa.fitCamera(
      CameraFit.coordinates(
        coordinates: ruta.puntos,
        padding: const EdgeInsets.fromLTRB(40, 170, 40, 90),
        maxZoom: 18,
      ),
    );
    if (!ruta.porCalles) {
      _mensaje('No se pudo trazar por calles: se muestra la línea recta.');
    }
    _revisarLlegada();
  }

  void _revisarLlegada() {
    final yo = _yo;
    final destino = _destino;
    if (yo == null || destino == null || _llego) return;
    final faltan = UbicacionService.distanciaMetros(yo, destino.punto);
    if (faltan <= kRadioLlegada) {
      setState(() => _llego = true);
      _mensaje('¡Llegaste a ${destino.nombre}!', error: false);
    }
  }

  void _terminarRuta() {
    setState(() {
      _destino = null;
      _ruta = null;
      _calculando = false;
      _llego = false;
    });
  }

  // ---------- Pantalla ----------

  @override
  Widget build(BuildContext context) {
    final yo = _yo;
    final ruta = _ruta;
    final destino = _destino;

    return Stack(
      fit: StackFit.expand, // el mapa ocupa toda la pestaña
      children: [
        FlutterMap(
          mapController: _mapa,
          options: MapOptions(
            initialCenter: kCentroInicial,
            initialZoom: kZoomInicial,
            onLongPress: (_, punto) => _nuevoLugar(punto),
          ),
          children: [
            TileLayer(
              urlTemplate: kUrlTeselas,
              userAgentPackageName: kPaqueteApp,
            ),
            // NUEVO: la ruta se dibuja debajo de los marcadores
            if (ruta != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: ruta.puntos,
                    strokeWidth: 6,
                    color: ruta.porCalles
                        ? FetColors.verde
                        : Colors.orange.shade800,
                  ),
                ],
              ),
            if (yo != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: yo,
                    radius: _precision,
                    useRadiusInMeter: true,
                    color: const Color(0x331565C0),
                    borderColor: const Color(0x881565C0),
                    borderStrokeWidth: 1,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final lugar in _lugares)
                  Marker(
                    point: lugar.punto,
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => _verLugar(lugar),
                      child: Icon(
                        Icons.location_on,
                        size: 44,
                        color: lugar.categoria.color,
                        shadows: const [
                          Shadow(blurRadius: 4, color: Colors.black38),
                        ],
                      ),
                    ),
                  ),
                if (yo != null)
                  Marker(
                    point: yo,
                    width: 26,
                    height: 26,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, color: Colors.black26),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: destino == null
              ? _panelInfo(yo)
              : _panelRuta(destino, ruta), // NUEVO
        ),
        Positioned(
          right: 12,
          bottom: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'fab-neiva',
                tooltip: 'Volver a Neiva',
                onPressed: () => _mapa.move(kCentroInicial, kZoomInicial),
                child: const Icon(Icons.location_city),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'fab-yo',
                tooltip: 'Mi ubicación',
                onPressed: _buscando ? null : _botonUbicacion,
                child: _buscando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panelInfo(LatLng? yo) {
    final titulo = yo == null
        ? 'Toca el botón de ubicación para encontrarte'
        : 'Estás en ${yo.latitude.toStringAsFixed(5)}, '
            '${yo.longitude.toStringAsFixed(5)} (± ${_precision.round()} m)';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              yo == null ? Icons.location_searching : Icons.my_location,
              color: FetColors.verde,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Mantén presionado el mapa para marcar un punto · '
                    '${_lugares.length} marcados',
                    style: const TextStyle(fontSize: 12, color: FetColors.gris),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: panel con el destino, la ruta y lo que falta
  Widget _panelRuta(Lugar destino, Ruta? ruta) {
    final yo = _yo;
    final faltan =
        yo == null ? null : UbicacionService.distanciaMetros(yo, destino.punto);
    String? resumen;
    if (ruta != null) {
      final tipo = ruta.porCalles ? 'Caminando' : 'Línea recta';
      resumen = '$tipo: ${formatoDistancia(ruta.distanciaMetros)} · '
          '${formatoDuracion(ruta.duracionSegundos)}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(destino.categoria.icono, color: destino.categoria.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hacia ${destino.nombre}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Terminar',
                  icon: const Icon(Icons.close),
                  onPressed: _terminarRuta,
                ),
              ],
            ),
            if (_calculando)
              const Padding(
                padding: EdgeInsets.only(right: 8, bottom: 8),
                child: LinearProgressIndicator(),
              )
            else if (resumen != null)
              Text(resumen),
            if (faltan != null)
              Text(
                _llego
                    ? '¡Llegaste!'
                    : 'Te faltan ${formatoDistancia(faltan)} en línea recta',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _llego ? FetColors.verde : FetColors.gris,
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _calculando ? null : () => _irA(destino),
                icon: const Icon(Icons.refresh),
                label: const Text('Recalcular desde aquí'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

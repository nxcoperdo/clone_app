import 'package:latlong2/latlong.dart';

/// Configuración general del mapa.
/// Punto inicial: centro de Neiva (aproximado).
const LatLng kCentroInicial = LatLng(2.9273, -75.2819);
const double kZoomInicial = 13;

/// Teselas (imágenes del mapa) de OpenStreetMap: gratis y sin API key.
const String kUrlTeselas = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Identifica tu app ante OpenStreetMap (lo exige su política de uso).
const String kPaqueteApp = 'co.edu.fet.fet_campus';

/// A cuántos metros del destino consideramos que ya llegaste.
const double kRadioLlegada = 25;

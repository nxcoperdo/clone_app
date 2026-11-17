import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lugar.dart';

/// Guarda los puntos del usuario en Firestore.
/// Ruta: usuarios/{uid}/lugares/{idLugar}
/// Las reglas del taller anterior ya protegen esta ruta.
class LugaresService {
  LugaresService(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('lugares');

  Stream<List<Lugar>> flujo() {
    return _coleccion
        .orderBy('creadoEn')
        .snapshots()
        .map(
          (consulta) => consulta.docs
              .map((doc) => Lugar.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// add() crea el documento con un id automático.
  Future<void> agregar(Lugar lugar) async {
    await _coleccion.add({
      ...lugar.toMap(),
      'creadoEn': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> eliminar(String id) async {
    await _coleccion.doc(id).delete();
  }
}

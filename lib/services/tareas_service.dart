import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/tareas_demo.dart';
import '../models/tarea.dart';

/// Lee y escribe las tareas de UN usuario en Firestore.
/// Ruta: usuarios/{uid}/tareas/{idTarea}
class TareasService {
  TareasService(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('tareas');

  /// Flujo en tiempo real: emite la lista cada vez que algo cambia.
  Stream<List<Tarea>> flujo() {
    return _coleccion
        .orderBy('creadaEn', descending: true)
        .snapshots()
        .map(
          (consulta) => consulta.docs
              .map((doc) => Tarea.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> agregar(Tarea tarea) {
    return _coleccion.doc(tarea.id).set({
      ...tarea.toMap(),
      'creadaEn': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> actualizar(Tarea tarea) {
    return _coleccion.doc(tarea.id).update(tarea.toMap());
  }

  Future<void> eliminar(String id) {
    return _coleccion.doc(id).delete();
  }

  /// Sube las 5 tareas de ejemplo en una sola operación (batch).
  Future<void> cargarEjemplos() {
    final lote = FirebaseFirestore.instance.batch();
    final ahora = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < tareasDemo.length; i++) {
      final tarea = tareasDemo[i];
      lote.set(_coleccion.doc(tarea.id), {
        ...tarea.toMap(),
        'creadaEn': ahora - i, // conserva el orden original
      });
    }
    return lote.commit();
  }
}

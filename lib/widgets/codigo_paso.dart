import 'package:flutter/material.dart';

import '../config/estudiante.dart';
import '../theme/fet_theme.dart';
import '../utils/verificacion.dart';

/// Recuadro que muestra el código que debes escribir en el taller.
class CodigoPaso extends StatelessWidget {
  const CodigoPaso({super.key, required this.paso, required this.clave});

  final String paso;
  final String clave;

  @override
  Widget build(BuildContext context) {
    final codigo = codigoVerificacion(kNombreEstudiante, clave);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: FetColors.verdeClaro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FetColors.verde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: FetColors.verde, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Código $paso: $codigo',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: FetColors.verdeOscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

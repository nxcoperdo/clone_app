import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/fet_theme.dart';

/// Muestra a qué proyecto de Firebase quedó conectada la app.
class EstadoFirebase extends StatelessWidget {
  const EstadoFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase.app() solo funciona si main() ya ejecutó initializeApp
    final proyecto = Firebase.app().options.projectId;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_done_outlined, color: FetColors.verde),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Conectado a Firebase: $proyecto',
            style: const TextStyle(color: FetColors.verdeOscuro),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/fet_theme.dart';

/// Logo de la FET construido solo con widgets (no necesita imágenes).
class FetLogo extends StatelessWidget {
  const FetLogo({super.key, this.ancho = 200, this.conTexto = true});

  final double ancho;
  final bool conTexto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Recuadro verde con las letras FET
          Container(
            width: ancho * 0.62,
            padding: const EdgeInsets.all(4),
            color: FetColors.verde,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: ancho * 0.03),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                'Coca-Cola',
                style: TextStyle(
                  fontFamily: 'cursive',
                  fontStyle: FontStyle.italic,
                  fontSize: ancho * 0.11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          // Nombre de la institución (opcional)
          if (conTexto) ...[
            SizedBox(height: ancho * 0.04),
            const FittedBox(
              child: Text(
                'THE COCA-COLA\nCOMPANY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 20,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: FetColors.verde,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(height: 1.5, color: FetColors.verde),
            const SizedBox(height: 4),
            const FittedBox(
              child: Text(
                'A L W A Y S   C O C A - C O L A',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  color: FetColors.gris,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

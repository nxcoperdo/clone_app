/// Genera el código de verificación de cada paso del taller.
/// El código depende de TU nombre, por eso es personal.
/// ¡No modifiques este archivo!
String codigoVerificacion(String nombre, String clave) {
  const reemplazos = {
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'Ü': 'U',
    'Ñ': 'N',
  };
  var base = nombre.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  reemplazos.forEach((letra, cambio) {
    base = base.replaceAll(letra, cambio);
  });
  final texto = '$base|$clave';
  var suma = 0;
  for (var i = 0; i < texto.length; i++) {
    suma = (suma + texto.codeUnitAt(i) * (i + 7)) % 9973;
  }
  return 'FET-${suma.toString().padLeft(4, '0')}';
}

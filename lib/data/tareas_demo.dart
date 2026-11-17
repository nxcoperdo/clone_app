import '../models/tarea.dart';

/// Datos de ejemplo ("quemados") para arrancar la app.
const List<Tarea> tareasDemo = [
  Tarea(
    id: 't1',
    titulo: 'Entregar taller de Flutter',
    materia: 'Desarrollo Móvil',
    prioridad: Prioridad.alta,
  ),
  Tarea(
    id: 't2',
    titulo: 'Leer sobre widgets con estado',
    materia: 'Desarrollo Móvil',
    completada: true,
  ),
  Tarea(
    id: 't3',
    titulo: 'Resolver guía de algoritmos',
    materia: 'Algoritmia',
  ),
  Tarea(
    id: 't4',
    titulo: 'Preparar exposición de IA',
    materia: 'Inteligencia Artificial',
    prioridad: Prioridad.alta,
  ),
  Tarea(
    id: 't5',
    titulo: 'Repasar bases de datos',
    materia: 'Bases de Datos',
    prioridad: Prioridad.baja,
  ),
];

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../services/auth_service.dart';
import '../services/tareas_service.dart';
import '../theme/fet_theme.dart';
import 'inicio_tab.dart';
import 'mapa_tab.dart'; // NUEVO
import 'perfil_tab.dart';
import 'tareas_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;
  List<Tarea> _tareas = [];
  bool _cargando = true;
  late final TareasService _servicio;
  StreamSubscription<List<Tarea>>? _suscripcion;

  static const _titulos = ['Inicio', 'Mis tareas', 'Mapa', 'Mi perfil']; // NUEVO: 4 títulos

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _servicio = TareasService(uid);
    _suscripcion = _servicio.flujo().listen(
      (lista) {
        if (!mounted) return;
        setState(() {
          _tareas = lista;
          _cargando = false;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _cargando = false);
        _mostrarError('No se pudieron leer las tareas: $error');
      },
    );
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  void _mostrarError(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _ejecutar(Future<void> operacion) async {
    try {
      await operacion;
    } on FirebaseException catch (e) {
      if (mounted) {
        _mostrarError('Firebase rechazó la operación: ${e.code}');
      }
    }
  }

  // Cambia la tarea en pantalla de inmediato (sin esperar a internet)
  void _reemplazarLocal(Tarea tarea) {
    setState(() {
      final i = _tareas.indexWhere((t) => t.id == tarea.id);
      if (i != -1) {
        _tareas[i] = tarea;
      }
    });
  }

  void _alternarTarea(Tarea tarea) {
    final editada = tarea.copyWith(completada: !tarea.completada);
    _reemplazarLocal(editada);
    _ejecutar(_servicio.actualizar(editada));
  }

  void _eliminarTarea(Tarea tarea) {
    // Se quita de la lista local YA, porque Dismissible lo exige
    setState(() => _tareas.removeWhere((t) => t.id == tarea.id));
    _ejecutar(_servicio.eliminar(tarea.id));
  }

  void _agregarTarea(Tarea tarea) {
    _ejecutar(_servicio.agregar(tarea));
  }

  void _actualizarTarea(Tarea tarea) {
    _reemplazarLocal(tarea);
    _ejecutar(_servicio.actualizar(tarea));
  }

  void _cargarEjemplos() {
    _ejecutar(_servicio.cargarEjemplos());
  }

  void _cerrarSesion() {
    AuthService().cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final paginas = <Widget>[
      InicioTab(tareas: _tareas),
      TareasTab(
        tareas: _tareas,
        onAlternar: _alternarTarea,
        onEliminar: _eliminarTarea,
        onAgregar: _agregarTarea,
        onActualizar: _actualizarTarea,
      ),
      const MapaTab(), // NUEVO: tercera pestaña
      PerfilTab(tareas: _tareas, onCerrarSesion: _cerrarSesion),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        backgroundColor: FetColors.verde,
        foregroundColor: Colors.white,
        actions: [
          if (!_cargando && _tareas.isEmpty)
            IconButton(
              tooltip: 'Cargar tareas de ejemplo',
              icon: const Icon(Icons.playlist_add),
              onPressed: _cargarEjemplos,
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : paginas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        indicatorColor: FetColors.verdeClaro,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Tareas',
          ),
          NavigationDestination( // NUEVO
            icon: Icon(Icons.map_outlined), // NUEVO
            selectedIcon: Icon(Icons.map), // NUEVO
            label: 'Mapa', // NUEVO
          ), // NUEVO
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

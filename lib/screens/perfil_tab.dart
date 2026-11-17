import 'package:firebase_auth/firebase_auth.dart'; // NUEVO
import 'package:flutter/material.dart';

import '../config/estudiante.dart';
import '../models/tarea.dart';
import '../theme/fet_theme.dart';
import '../widgets/fet_logo.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({
    super.key,
    required this.tareas,
    required this.onCerrarSesion,
  });

  final List<Tarea> tareas;
  final VoidCallback onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    // NUEVO: los datos ahora vienen del usuario de Firebase
    final usuario = FirebaseAuth.instance.currentUser;
    final correo = (usuario?.email ?? 'sin-correo').toLowerCase();
    final uid = usuario?.uid ?? '-';
    final nombreFirebase = usuario?.displayName ?? '';
    final nombre =
        nombreFirebase.isNotEmpty ? nombreFirebase : kNombreEstudiante;

    final completadas = tareas.where((t) => t.completada).length;
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final iniciales = partes.isEmpty
        ? '?'
        : partes.take(2).map((p) => p[0].toUpperCase()).join();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 46,
            backgroundColor: FetColors.verde,
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          nombre,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Text(
          kPrograma,
          textAlign: TextAlign.center,
          style: TextStyle(color: FetColors.gris),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Correo'),
                subtitle: Text(correo), // NUEVO
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('UID en Firebase'),
                subtitle: SelectableText(uid), // NUEVO
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.task_alt),
                title: const Text('Tareas completadas'),
                subtitle: Text('$completadas de ${tareas.length}'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onCerrarSesion,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 24),
        const Center(child: FetLogo(ancho: 120)),
      ],
    );
  }
}

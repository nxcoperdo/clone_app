import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/fet_theme.dart';
import '../widgets/estado_firebase.dart';
import '../widgets/fet_logo.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController(); // NUEVO: correo en vez de usuario
  final _claveCtrl = TextEditingController();
  final _auth = AuthService(); // NUEVO
  bool _ocultarClave = true;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  String? _validarCorreo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Escribe tu correo';
    }
    if (!texto.contains('@') || !texto.contains('.')) {
      return 'El correo no es válido';
    }
    return null;
  }

  String? _validarClave(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Escribe tu contraseña';
    }
    if (valor.length < 6) {
      return 'Firebase exige mínimo 6 caracteres';
    }
    return null;
  }

  void _mostrarMensaje(String texto, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : FetColors.verde,
      ),
    );
  }

  // NUEVO: ahora pregunta a Firebase en lugar de comparar datos quemados
  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _cargando = true);
    try {
      await _auth.iniciarSesion(_correoCtrl.text, _claveCtrl.text);
      // No navegamos: AuthGate detecta la sesión y muestra HomeScreen.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _mostrarMensaje(AuthService.mensajeDeError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  // NUEVO: Firebase envía un correo para cambiar la contraseña
  Future<void> _recuperarClave() async {
    final correo = _correoCtrl.text.trim();
    if (_validarCorreo(correo) != null) {
      _mostrarMensaje('Escribe tu correo arriba y vuelve a tocar este botón.');
      return;
    }
    try {
      await _auth.recuperarClave(correo);
      if (mounted) {
        _mostrarMensaje(
          'Te enviamos un correo para restablecer la contraseña.',
          error: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _mostrarMensaje(AuthService.mensajeDeError(e));
      }
    }
  }

  void _abrirRegistro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const FetLogo(ancho: 220),
                    const SizedBox(height: 24),
                    const Text(
                      'Ingresa con tu cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: FetColors.verdeOscuro,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _correoCtrl,
                      validator: _validarCorreo,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _claveCtrl,
                      obscureText: _ocultarClave,
                      validator: _validarClave,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _ingresar(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarClave
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _ocultarClave = !_ocultarClave);
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _cargando ? null : _recuperarClave,
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _cargando ? null : _ingresar,
                        child: _cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Ingresar'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // NUEVO: enlace para crear cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: _cargando ? null : _abrirRegistro,
                          child: const Text('Crear cuenta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const EstadoFirebase(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

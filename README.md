# clone_app

App de práctica en Flutter: una pantalla de **login quemado** (credenciales fijas en el código, sin backend) que, al loguearse, navega a una pantalla de **saludo**.

## Cómo correrla

```bash
flutter run
```

Credenciales de login:
- Usuario: `usuario`
- Contraseña: `1234`

## Estructura

Todo el código vive en un único archivo: [lib/main.dart](lib/main.dart). Tiene tres partes: `main()`, `PantallaLogin` y `PantallaInicio`.

## Las partes que más importan

Todo lo demás en el archivo (`hintText`, `border`, `obscureText`, el título del `AppBar`, los `SizedBox`) es decoración: se puede borrar y el login sigue funcionando igual, solo se ve más feo. Lo que **sí** es esencial:

1. **Las variables de estado** — sin esto no hay dónde guardar nada:
   ```dart
   String usuario = '';
   String contrasena = '';
   String error = '';
   ```

2. **Los `onChanged` de los `TextField`** — conectan lo que el usuario escribe con las variables:
   ```dart
   onChanged: (texto) { usuario = texto; }
   ```

3. **La lógica del botón** — el corazón del login: compara contra valores fijos y decide si navega o muestra error:
   ```dart
   onPressed: () {
     if (usuario == 'usuario' && contrasena == '1234') {
       Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaInicio()));
     } else {
       setState(() { error = 'Usuario o contraseña incorrectos'; });
     }
   }
   ```

4. **El `Text` que muestra `error`** — sin él, aunque cambies la variable, no se ve nada en pantalla.

5. **`setState()`** — no es una parte física del código, sino el mecanismo que hace que el cambio de `error` se refleje visualmente.

### `main()`

Es el punto de arranque de toda app Flutter. Llama a `runApp` con un `MaterialApp`, que le da a la app los estilos y comportamientos básicos de Material Design. La propiedad `home` define cuál es la primera pantalla que se muestra: `PantallaLogin`.

### `PantallaLogin` — la pantalla de login

Es un `StatefulWidget`. Un widget es "Stateful" cuando necesita **recordar datos que cambian** mientras el usuario interactúa con él (a diferencia de un `StatelessWidget`, que una vez dibujado no cambia). Aquí hace falta porque necesitamos guardar lo que el usuario escribe y si hubo un error.

Un `StatefulWidget` siempre viene acompañado de una clase `State` (aquí `_PantallaLoginState`), que es donde realmente viven esos datos:

```dart
String usuario = '';
String contrasena = '';
String error = '';
```

El método `build()` es el que "dibuja" la pantalla. Se vuelve a ejecutar cada vez que algo cambia, y retorna el árbol de widgets visibles:

- **`Scaffold`**: da la estructura base de una pantalla (barra superior + contenido).
- **`Column`**: acomoda los widgets hijos uno debajo del otro.
- **Dos `TextField`** (usuario y contraseña): cada uno tiene un `onChanged`, una función que Flutter llama automáticamente cada vez que el usuario teclea algo. Ahí simplemente guardamos el texto en la variable correspondiente. La contraseña usa `obscureText: true` para mostrar puntos en vez del texto real.
- **Un `Text`** que muestra el mensaje de `error` (si está vacío, no se ve nada).
- **Un `ElevatedButton`** con la lógica del login, en su `onPressed`:

```dart
onPressed: () {
  if (usuario == 'usuario' && contrasena == '1234') {
    // credenciales correctas → cambia de pantalla
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaInicio()),
    );
  } else {
    // credenciales incorrectas → muestra un mensaje de error
    setState(() {
      error = 'Usuario o contraseña incorrectos';
    });
  }
}
```

Esto es el "login quemado": no hay servidor ni base de datos, solo se compara el texto escrito contra dos valores fijos escritos directamente en el código (`'usuario'` y `'1234'`).

### Los widgets básicos: entry, label y botón

Estos tres son las piezas visuales con las que interactúa el usuario. En Flutter no se llaman "entry" o "label" — esos son nombres de otros frameworks (como Tkinter en Python) — pero cumplen el mismo rol:

**El "entry" → `TextField`**

Es la caja donde el usuario escribe.

```dart
TextField(
  decoration: const InputDecoration(
    labelText: 'Usuario',
    hintText: 'Escribe tu usuario',
    border: OutlineInputBorder(),
  ),
  onChanged: (texto) {
    usuario = texto;
  },
)
```

- `decoration` / `InputDecoration` es solo lo visual: `labelText` es la etiqueta flotante ("Usuario"), `hintText` es el texto gris de ejemplo, `border` dibuja el recuadro. Nada de esto afecta el funcionamiento.
- `onChanged` es lo único funcional: es una función que Flutter ejecuta **cada vez que cambia el texto** (cada tecla), y te da el texto actual como parámetro (`texto`). Aquí simplemente lo guardamos en la variable `usuario`.
- El campo de contraseña es el mismo widget, con `obscureText: true` agregado para tapar lo escrito con puntos.

**El "label" → `Text`**

Es el widget más simple: solo muestra texto fijo o una variable, no es interactivo.

```dart
Text(
  error,
  style: const TextStyle(fontSize: 16, color: Colors.red),
)
```

Muestra el contenido de la variable `error`. Como no tiene `onPressed` ni `onChanged`, no reacciona a nada — solo se redibuja cuando algo externo (`setState`) cambia el valor que le pasas. `style` es puramente visual (tamaño y color).

**El botón → `ElevatedButton`**

```dart
ElevatedButton(
  child: const Text('Iniciar sesión'),
  onPressed: () {
    // ... la lógica del login
  },
)
```

- `child` es lo que se muestra *dentro* del botón — en este caso, otro `Text`. Por eso puedes poner cualquier widget dentro de un botón (un ícono, una fila con ícono + texto, etc.), no solo texto plano.
- `onPressed` es la función que se ejecuta cuando el usuario toca el botón. Si le pasaras `onPressed: null`, el botón se vería "apagado" (gris) y no haría nada al tocarlo — así es como Flutter deshabilita botones.

En resumen: `TextField` **recibe** datos del usuario, `Text` **muestra** datos, y `ElevatedButton` **dispara una acción**. Esa combinación (entrada → lógica → salida) es el patrón que se repite en casi cualquier formulario, no solo en este login.

### La navegación: qué es lo que hace que cambie de pantalla

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const PantallaInicio()),
);
```

Esta única línea es la responsable de "saltar" de `PantallaLogin` a `PantallaInicio`. Se puede desarmar en tres piezas:

- **`Navigator`**: cada app Flutter tiene un `Navigator` que maneja las pantallas como una **pila** (como una pila de platos: el último que pones es el que se ve, y solo puedes quitar el de arriba). No es algo que tú creas, ya viene incluido por usar `MaterialApp`.
- **`MaterialPageRoute(builder: (context) => const PantallaInicio())`**: define **qué** pantalla se va a agregar a la pila. El `builder` es una función que Flutter llama cuando necesita construir esa pantalla nueva, y retorna el widget de la pantalla destino (`PantallaInicio()`). Aquí es donde decides a *cuál* pantalla vas — si quisieras ir a otra, solo cambiarías esto.
- **`Navigator.push(context, ...)`**: es el verbo, la acción de "agregar esa ruta arriba de la pila". El `context` es necesario porque le dice a Flutter *en qué parte del árbol de widgets* está pasando esto (cada widget tiene su propio `context`).

Al ejecutarse `push`, Flutter pone `PantallaInicio` arriba de `PantallaLogin` en la pila y **la dibuja en pantalla** — por eso "se ve" el cambio. `PantallaLogin` no se destruye, solo queda debajo, escondida. Por eso en `PantallaInicio` aparece automáticamente una flecha de "volver atrás" en el `AppBar`: Flutter la agrega sola porque detecta que hay algo debajo en la pila a lo que se puede volver. Esa flecha (o `Navigator.pop(context)` en código) simplemente quita la pantalla de arriba de la pila, y vuelve a mostrarse la que quedó debajo — en este caso, el login.

Si en el `if` cambiaras `Navigator.push` por, por ejemplo, solo un `print(...)`, las credenciales seguirían siendo correctas pero **nunca cambiarías de pantalla** — esa es la línea exacta que produce el desplazamiento visual.

**`setState()`** es distinto de solo cambiar una variable. Cuando escribes en un `TextField` (`onChanged`), no hace falta `setState` porque no necesitas redibujar nada en ese instante — solo guardas el valor para usarlo después. Pero cuando cambias algo que se **ve** en pantalla (como el mensaje de error), tienes que envolver el cambio en `setState(() { ... })`; si no, la variable cambia pero Flutter nunca se entera de que debe volver a dibujar esa parte, y en pantalla no se actualiza nada.

### `PantallaInicio` — la pantalla de saludo

Es la pantalla original del proyecto, sin cambios. También es `StatefulWidget`, por la misma razón: guarda el `nombre` que escribes y el `mensaje` que se muestra.

- Un `TextField` guarda lo que escribes en `nombre` (otra vez, con `onChanged`, sin `setState`).
- Un botón "Saludar" sí usa `setState` para actualizar `mensaje`, porque ese cambio debe reflejarse en pantalla:

```dart
onPressed: () {
  setState(() {
    mensaje = nombre.trim().isEmpty
        ? 'Primero escribe tu nombre'
        : 'Hola, ${nombre.trim()}';
  });
}
```

## La idea clave para entender todo el archivo

> Guardar lo que el usuario escribe → variable simple, no necesita redibujar nada.
> Cambiar algo que se **ve** en pantalla → `setState`, para avisarle a Flutter que debe redibujar.

## Ejercicios para practicar

1. Cambia la contraseña `'1234'` por otra y comprueba que el login deja de aceptar la anterior.
2. Agrega un botón "Cerrar sesión" en `PantallaInicio` que haga `Navigator.pop(context)` para volver al login.
3. Quita el `setState` del bloque de error (deja solo `error = '...'`) y observa que el mensaje ya no aparece en pantalla, aunque la variable sí cambió. Eso te confirma para qué sirve `setState`.
4. Agrega validación: si el usuario deja algún campo vacío, muestra un error distinto ("Completa todos los campos") sin llegar a comparar las credenciales.

## Recursos de Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

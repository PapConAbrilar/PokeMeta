# Contexto de desarrollo — PokeMeta

## Propósito

Aplicación Flutter para jugadores competitivos de Pokémon TCG. El README de la raíz, [`README.md`](./README.md), describe el objetivo del producto y los nueve requisitos de la asignatura. Este archivo deja constancia del estado del proyecto, del reparto de trabajo y de los puntos donde el frontend espera la integración del backend, para retomar el trabajo en otra sesión.

## Reparto del trabajo

- **Frontend (Flutter):** pantallas (salvo acceso y perfil), navegación, paso de parámetros, animaciones, formulario validado, widgets reutilizables y estado global con Provider.
- **Backend, APIs y pantallas de acceso y perfil (compañero):** autenticación con Supabase, tabla de mazos con RLS, consumo de las APIs externas, los servicios que entregan los datos y las pantallas `login_screen.dart`, `profile_screen.dart` y `trainer_details_screen.dart`.

El frontend usa hoy datos de ejemplo locales. Los puntos donde deben conectarse los datos reales están descritos en la sección “Guía de integración para backend”; los de mazos además llevan comentarios `INTEGRACIÓN` en el código.

## Estructura actual

El proyecto Flutter está en `pokemeta/`.

```text
pokemeta/lib/
├── main.dart
├── models/
│   ├── card_model.dart
│   ├── deck_model.dart
│   └── tournament_model.dart
├── providers/
│   ├── active_deck_provider.dart
│   └── decks_provider.dart
├── widgets/
│   ├── active_deck_banner.dart
│   ├── card_image.dart
│   ├── custom_stat_row.dart
│   ├── pokemon_card_tile.dart
│   ├── stat_badge_widget.dart
│   └── tournament_row_card.dart
└── presentation/screens/
    ├── login/login_screen.dart
    ├── main_navigation_screen.dart
    ├── home/home_screen.dart
    ├── cards/card_detail_screen.dart
    ├── decks/
    │   ├── active_deck_screen.dart
    │   ├── card_picker_screen.dart
    │   ├── decks_screen.dart
    │   ├── deck_detail_screen.dart
    │   └── deck_form_screen.dart
    ├── tournaments/tournament_detail_screen.dart
    └── profile/
        ├── profile_screen.dart
        └── trainer_details_screen.dart
```

### Qué hace cada archivo

- `main.dart`: inicia `PokeMetaApp` y muestra `LoginScreen`. Usa el tema estándar de Material (`ThemeData()`); aún no hay paleta propia.
- `login/login_screen.dart`: campos de correo y contraseña, “Recordarme” y botones de acceso/registro. El acceso navega a la app **sin autenticar ni validar**; registro y recuperación no tienen acción.
- `main_navigation_screen.dart`: navegación inferior entre Inicio, Mazos y Perfil. Conserva las pestañas con `IndexedStack`.
- `home/home_screen.dart`: resumen y selector Torneos/Cartas. Torneos lista `sampleTournaments` y abre `TournamentDetailScreen`. Cartas tiene búsqueda y filtros sin acción, y una grilla de `PokemonCardTile` que abre `CardDetailScreen`.
- `cards/card_detail_screen.dart`: detalle de carta (recibe `CardModel` por constructor). Es `StatefulWidget`: guarda si la carta es favorita **solo en memoria** y la anima con `AnimatedContainer` y `AnimatedScale`. “Agregar al mazo activo” usa `ActiveDeckProvider`.
- `decks/decks_screen.dart`: lista de mazos guardados, leída de `DecksProvider`. “Nuevo mazo” y “Editar datos” abren `DeckFormScreen` y reciben el resultado con `await Navigator.push`. “Eliminar” no tiene acción.
- `decks/active_deck_screen.dart`: editor del borrador (ver cartas, ajustar copias, agregar, guardar o descartar). Un mazo nuevo pide nombre, formato y descripción con `DeckFormScreen` al guardar.
- `decks/card_picker_screen.dart`: selector con búsqueda para agregar cartas al borrador (recibe `cards` por constructor).
- `decks/deck_form_screen.dart`: formulario de crear/editar mazo con `Form`, `TextFormField` y `validator`. Devuelve un `DeckModel` con `Navigator.pop`.
- `decks/deck_detail_screen.dart`: detalle del mazo. “Editar datos” abre el formulario; “Editar cartas” carga el mazo como borrador en `ActiveDeckProvider` y abre `ActiveDeckScreen`. Cada carta abre su detalle.
- `tournaments/tournament_detail_screen.dart`: detalle de torneo (recibe `TournamentModel` por constructor). La sección “Clasificación” es un estado vacío a la espera de datos.
- `profile/profile_screen.dart`: perfil de ejemplo. “Datos del entrenador” abre sus estadísticas y “Cerrar sesión” vuelve al acceso limpiando la pila de navegación. No hay autenticación real.
- `profile/trainer_details_screen.dart`: mazo más utilizado y carta favorita como ejemplos enlazados a sus detalles.
- `widgets/`: componentes reutilizables (requisito 8). `CardImage` incluye el `Hero` de la carta.

## Estado de los requisitos del README

| # | Requisito | Estado | Responsable |
|---|---|---|---|
| 1 | Login y autenticación Supabase | **Pendiente.** Hay pantalla de acceso, sin autenticación real. | Backend |
| 2 | Consumo de API con `FutureBuilder` | **Pendiente.** Todos los datos son de ejemplo. | Backend (servicios) + Frontend (`FutureBuilder`, carga y error) |
| 3 | Navegación a detalle pasando parámetros | **Cubierto.** Carta (desde grilla y desde mazo), mazo y torneo reciben su modelo por el constructor. | Frontend |
| 4 | Animaciones `Hero` e implícitas | **Cubierto.** `Hero` en la imagen de carta (grilla, mazo y detalle) y `AnimatedScale` + `AnimatedContainer` en la estrella de favorita. | Frontend |
| 5 | CRUD de mazos con Supabase y RLS | **Pendiente.** La lista es local y se pierde al reiniciar. | Backend |
| 6 | Formulario con validación | **Cubierto en el frontend** (`DeckFormScreen`). Falta conectar con la persistencia. | Frontend |
| 7 | Estado global con Provider | **Cubierto.** `ActiveDeckProvider` (borrador del mazo que se arma o edita) y `DecksProvider` (mazos guardados) comparten estado entre Inicio, detalle de carta, lista y detalle de mazo, y el editor de mazo activo. Viven solo en memoria. | Frontend |
| 8 | Widgets propios reutilizables | **Cubierto.** Seis widgets en `lib/widgets/`. | Frontend |
| 9 | Flujo colaborativo en GitHub | **No evaluado.** Es de historial y colaboración. | Todos |

## Guía de integración para backend

### 1. Contratos de los modelos

Los modelos están en `lib/models/`. Todos son inmutables (campos `final`, constructor `const`). Falta agregarles `fromJson` (y `toJson` en los que se envían) cuando se conozca la forma de las respuestas.

**`TournamentModel`**

| Campo | Tipo | Notas |
|---|---|---|
| `name` | `String` | |
| `city` | `String` | |
| `date` | `String` | Hoy texto ya formateado (“18 de abril”). Si la API entrega fecha, convertir antes de crear el modelo o cambiar el tipo a `DateTime` y formatear en los widgets. |
| `winningDeck` | `String` | |
| `players` | `int` | |

**`CardModel`**: `name`, `expansion`, `rarity`, `cardNumber`, `hp` (`int`), `type`, `ability`, `attack`, `attackDamage`, `attackDescription`, `retreatCost` (`int`), `weakness`, `resistance`, `regulationMark` (todos `String` salvo los indicados).

- `cardNumber` se usa como etiqueta del `Hero`, así que **debe ser único** por carta.
- No existe aún un campo de imagen. Hay que agregar `imageUrl` a `CardModel` y mostrarla en `widgets/card_image.dart`, que es el único lugar donde se dibuja la imagen (hoy muestra un ícono de reemplazo).
- `copiesInActiveDeck` se eliminó de `CardModel`: las copias en el mazo activo las lleva `ActiveDeckProvider`.

**`DeckModel`**

| Campo | Tipo | Notas |
|---|---|---|
| `name` | `String` | Validado en el formulario: 3 a 30 caracteres. |
| `format` | `String` | Hoy solo `Estándar` o `Expandido`. |
| `description` | `String` | Validada en el formulario: 10 a 200 caracteres. |
| `cards` | `List<DeckCardEntry>` | Cada entrada es una carta (`CardModel`) y una cantidad (`count`). |

`cardCount` es un getter calculado (suma de cantidades). No se guarda.

Propuesta de tabla (a confirmar con el backend): `decks` con `id`, `user_id` (por defecto `auth.uid()`), `name`, `format`, `description`, `created_at`, y una tabla de relación (por ejemplo `deck_cards` con `deck_id`, `card_id` y `count`) o una columna `jsonb` para las cartas. RLS: cada usuario solo puede leer, crear, actualizar y eliminar filas con su `user_id`. Conviene reflejar en la base las mismas reglas de longitud y los formatos válidos que valida el formulario.

### 2. Datos de ejemplo a reemplazar

| Dato de ejemplo | Dónde se usa |
|---|---|
| `sampleCards` (`card_model.dart`) | Grilla de cartas en `home_screen.dart` |
| `sampleDecks` (`deck_model.dart`) | `_decks` en `providers/decks_provider.dart` |
| `sampleTournaments` (`tournament_model.dart`) | Lista de torneos en `home_screen.dart` |

Al conectar los datos reales habrá que agregar estados de **carga**, **error** y **lista vacía** en esas pantallas. Se recomienda que los servicios (`lib/services/`) devuelvan `Future<List<Modelo>>` para usarlos directamente en un `FutureBuilder`.

### 3. Puntos de conexión en el código

Los puntos de mazos llevan comentarios `INTEGRACIÓN` en el código. Los de login, perfil y `main.dart` no llevan comentario:

- `providers/decks_provider.dart`: **punto único de integración de mazos.** `_decks` se reemplaza por los mazos de Supabase; `add` y `replace` deben llamar a crear y actualizar. Falta `delete`. Desde la UI todo pasa por este provider (lista, formulario, detalle y editor de cartas).
- `decks_screen.dart`, menú ⋮: “Eliminar” no tiene acción (falta confirmación y borrado).
- `card_picker_screen.dart`: hoy usa `sampleCards`; pasar aquí la colección del usuario cuando exista.
- `login_screen.dart`: reemplazar la navegación directa por `signIn` y `signUp` de `supabase_flutter`, validando credenciales y mostrando errores.
- `profile_screen.dart`: “Cerrar sesión” debe llamar a `signOut` y limpiar el estado: `context.read<ActiveDeckProvider>().discard()` y recargar `DecksProvider`, para que el siguiente usuario no vea datos del anterior.
- `main.dart`: inicializar Supabase antes de `runApp`.

### 4. Dependencias pendientes en `pubspec.yaml`

Hoy están `flutter`, `cupertino_icons` y `provider`. Faltan `supabase_flutter` y `http`. No guardar claves ni URLs de Supabase en el repositorio; usar `--dart-define` o un archivo de configuración ignorado por Git.

### 5. Datos que hoy solo viven en memoria

- Favoritas: el estado vive en `CardDetailScreen` y se pierde al salir de la pantalla.
- Mazo activo (borrador): `ActiveDeckProvider` guarda en memoria el mazo que se arma o edita (máximo 60 cartas y 4 copias por carta). Al guardar, el resultado pasa a `DecksProvider`, que es donde se persiste. Un mazo guardado no cambia hasta pulsar “Guardar cambios”.
- Datos del entrenador y torneos de ejemplo del perfil.
- Clasificación del torneo: pantalla de detalle con estado vacío.

## Verificación registrada

El desarrollador ejecutó la app con `flutter run` (Chrome) y comprobó manualmente la navegación, las animaciones y el formulario. `flutter analyze` no reportó problemas tras agregar el Provider. **Falta registrar** `flutter test` y volver a ejecutar `flutter analyze` tras los últimos cambios. La prueba existente recorre el acceso, las pestañas, los detalles y el cierre de sesión, y puede necesitar ajustes por las pantallas nuevas.

## Punto de continuación

1. **Frontend:** definir tema y paleta propios; implementar “Eliminar” mazo; completar búsqueda, filtros y “Agregar al mazo activo”.
2. **Backend (compañero):** autenticación y pantallas de acceso y perfil, tabla de mazos con RLS, servicios de API y `fromJson` de los modelos.
3. **Coordinación:** acordar los campos de los modelos antes de conectar, y quién escribe cada `FutureBuilder`.

## Pendientes y notas de sesión

- **Decisión de diseño:** el mazo activo es el borrador del mazo que se arma o edita (`ActiveDeckProvider`); los mazos guardados viven en `DecksProvider`. Se descartó la alternativa de editar cada mazo guardado por separado.
- **Contexto de aprendizaje:** es el primer proyecto Flutter del desarrollador frontend, que debe poder defender y explicar todo el código. Cada parte se trabajó con concepto, código y preguntas de defensa (estas últimas solo quedaron en el chat).
- **Sin verificar:** `login_screen.dart`, `profile_screen.dart` y `trainer_details_screen.dart` quedan a cargo del compañero y no se revisaron en la sesión de frontend. `flutter test` puede fallar: la app ahora necesita `MultiProvider` en `main.dart`, y el test debe envolver la app con los mismos providers.
- **Entorno:** SDK de Flutter en `C:\Users\sebal\flutter` (ya en el PATH). El repositorio está en OneDrive, que puede bloquear archivos temporales. El Android toolchain no está instalado; se prueba en Chrome.
- **Git:** rama `feature/widgets-reutilizables` con commits locales; el `push` queda pendiente para el final de la sesión.
- **Pendiente de producto:** eliminar mazo, búsqueda y filtros de Inicio, tema y paleta propios, colección del usuario (hoy el selector usa todo el catálogo) y persistencia de favoritas.

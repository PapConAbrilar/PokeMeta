# 🃏 PokéMeta Deck & Tracker

Aplicación móvil desarrollada en **Flutter** para jugadores competitivos de Pokémon Trading Card Game (TCG). Permite explorar resultados de torneos (esports/deporte mental), consultar el catálogo oficial de cartas y construir/gestionar mazos personalizados en la nube.

Proyecto Integrador desarrollado para la asignatura **IIP323W — Tecnologías y Aplicaciones Web y Móviles** (Universidad del Desarrollo, 2026).

---

## 📋 Cumplimiento de Requisitos de la Asignatura

Este repositorio ha sido estructurado para cumplir con los 9 criterios de evaluación del curso:

1. **Login con Supabase:** Autenticación completa de usuarios (`SignUp`, `SignIn`, `SignOut`) gestionada mediante `supabase_flutter`.
2. **Datos de la API (`FutureBuilder`):** Consumo asíncrono de APIs REST para listar torneos competitivos recientes, posiciones (*standings*) y el catálogo de cartas de Pokémon TCG.
3. **Navegación con paso de parámetros:** Selección de cartas, mazos o torneos que navegan hacia una vista de detalle (`CardDetailScreen` / `DeckDetailScreen` / `TournamentDetailScreen`), pasando el modelo de datos directamente por el constructor del widget.
4. **Animaciones:**
   * **Hero:** Transición fluida de la imagen de la carta desde la grilla principal (y desde el contenido de un mazo) hasta la pantalla de inspección detallada.
   * **Animación Implícita:** Uso de `AnimatedScale` y `AnimatedContainer` para dar *feedback* visual interactivo al marcar cartas favoritas (y, más adelante, al agregarlas al mazo).
5. **Tabla en Supabase con RLS (CRUD):** Almacenamiento de los mazos de cada jugador en PostgreSQL (Supabase) con políticas de *Row Level Security* (RLS) activas para que cada usuario solo pueda crear, leer, actualizar y eliminar sus propios registros
6. **Formulario con validación:** Implementación de `Form` y `TextFormField` con reglas de validación (`validator`) para la creación y edición de mazos (nombre de 3 a 30 caracteres, formato de juego obligatorio y descripción de 10 a 200 caracteres)
7. **Estado Global con Provider:** Uso de `ChangeNotifier` (`ActiveDeckProvider`) compartido entre múltiples pantallas para gestionar en tiempo real el contador y listado de cartas del mazo en construcción, y `DecksProvider` para la lista de mazos guardados
8. **Widgets propios reutilizables:** Componentes modulares extraídos en sus propios archivos dentro de `lib/widgets/` (`PokemonCardTile`, `CardImage`, `StatBadgeWidget`, `CustomStatRow`, `TournamentRowCard`, `ActiveDeckBanner`)
9. **Flujo colaborativo en GitHub:** Historial de commits distribuido entre todos los integrantes del equipo según sus roles asignados.

---

## 🚦 Estado de Implementación

| # | Requisito | Estado |
|---|---|---|
| 1 | Login con Supabase | Pendiente (hay pantalla, sin autenticación real) |
| 2 | Datos de la API con `FutureBuilder` | Pendiente (datos de ejemplo) |
| 3 | Navegación con paso de parámetros | Implementado |
| 4 | Animaciones (`Hero` e implícitas) | Implementado |
| 5 | Tabla en Supabase con RLS (CRUD) | Pendiente |
| 6 | Formulario con validación | Implementado (falta conectar la persistencia) |
| 7 | Estado global con Provider | Implementado (en memoria) |
| 8 | Widgets propios reutilizables | Implementado |
| 9 | Flujo colaborativo en GitHub | En curso |

El detalle del reparto de trabajo, los contratos de los modelos y los puntos de conexión con el backend están en [`CONTEXTO_DESARROLLO.md`](./CONTEXTO_DESARROLLO.md).

---

## 🛠️ Stack Tecnológico y Dependencias

* **Framework:** Flutter & Dart
* **Backend & Auth:** [Supabase](https://supabase.com/) (`supabase_flutter`) — *pendiente de agregar a `pubspec.yaml`*
* **Gestión de Estado:** `provider` (`ChangeNotifier`)
* **Cliente HTTP:** `http` — *pendiente de agregar a `pubspec.yaml`*
* **APIs Externas:**
  * [Limitless TCG API](https://docs.limitlesstcg.com/) / [TopDeck.gg API](https://topdeck.gg/docs/tournaments-v2) — Datos de torneos competitivos, *standings* y *decklists*.
  * [Pokémon TCG API](https://pokemontcg.io/) / [TCGdex API](https://tcgdex.dev/) — Imágenes de cartas en alta resolución, estadísticas y expansiones.

---

## 📂 Estructura del Proyecto

El proyecto Flutter está en la carpeta `pokemeta/`.

```text
pokemeta/lib/
├── main.dart                        # Punto de entrada con MultiProvider (pendiente: inicializar Supabase)
├── models/                          # Modelos de datos
│   ├── card_model.dart              #   CardModel + datos de ejemplo
│   ├── deck_model.dart              #   DeckModel, DeckCardEntry + datos de ejemplo
│   └── tournament_model.dart        #   TournamentModel + datos de ejemplo
├── providers/                       # ChangeNotifiers: ActiveDeckProvider (borrador) y DecksProvider (mazos guardados)
├── services/                        # (pendiente) Consumo de API REST y cliente de Supabase
├── widgets/                         # Widgets propios reutilizables, un archivo por widget
│   ├── active_deck_banner.dart
│   ├── card_image.dart              #   Imagen de carta con Hero
│   ├── custom_stat_row.dart
│   ├── pokemon_card_tile.dart
│   ├── stat_badge_widget.dart
│   └── tournament_row_card.dart
└── presentation/screens/            # Pantallas de la aplicación
    ├── login/login_screen.dart                  # Acceso y registro
    ├── main_navigation_screen.dart              # Navegación inferior (Inicio, Mazos, Perfil)
    ├── home/home_screen.dart                    # Explorador de torneos y cartas
    ├── cards/card_detail_screen.dart            # Detalle de carta (Hero + animación implícita)
    ├── decks/
    │   ├── active_deck_screen.dart              # Editor del mazo en construcción (Provider)
    │   ├── card_picker_screen.dart              # Selector de cartas para agregar al mazo
    │   ├── decks_screen.dart                    # Lista de mazos
    │   ├── deck_detail_screen.dart              # Detalle de mazo, con edición
    │   └── deck_form_screen.dart                # Formulario validado de mazos
    ├── tournaments/tournament_detail_screen.dart # Detalle de torneo
    └── profile/                                 # Perfil y datos del entrenador
```

---

## ▶️ Ejecución

Desde la carpeta `pokemeta/`:

```bash
flutter pub get
flutter run -d chrome
```

Con la app en ejecución, `r` hace *hot reload* y `R` *hot restart*.

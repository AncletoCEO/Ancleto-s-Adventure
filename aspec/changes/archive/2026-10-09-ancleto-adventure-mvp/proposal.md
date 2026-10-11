# Proposal: Ancleto's Adventure — MVP estilo Pacman

## Problem

El usuario tiene tres modelos 3D de Ancleto (`Ancleto1.glb`, `Ancleto2.glb`, `Ancleto3.glb`) que son **mallas estáticas** (sin esqueleto ni animaciones) y quiere un juego jugable estilo Pacman donde Ancleto recoge tazas de café esquivando enemigos en mapas generados proceduralmente.

Hoy el repositorio solo contiene esos `.glb`: no existe proyecto Godot (`project.godot`), ni assets, ni pipeline de contenido, ni integración entre el agente y el editor. Godot 4.7.2 está instalado en el sistema (`/usr/bin/godot`) pero sin proyecto ni forma de que el agente lo opere.

Sin un proyecto, un bucle de juego y una fuente de mapas, no hay nada jugable. Y sin la integración MCP, el agente no puede construir ni verificar el juego dentro del editor.

## Proposed change

Crear el proyecto Godot 4.7 **Ancleto's Adventure** e implementar un **MVP jugable estilo Pacman en 3D en tercera persona**:

- **Ancleto** (una de 3 variantes GLB elegibles por el jugador) se mueve **libremente** por un laberinto en 3D con **cámara en tercera persona** (mouse look, movimiento relativo a la cámara).
- El laberinto se **genera proceduralmente** en cada nivel, garantizando conectividad total.
- El objetivo es **recoger todas las tazas de café**; al lograrlo se genera un nuevo mapa (nivel +1).
- **Enemigos** con IA de persecución dañan al jugador al contacto; perder todas las vidas termina la partida.
- **HUD** con tazas restantes, vidas y nivel, más una pantalla de **selección de personaje**.
- **Ancleto riggeado y animado**: los 3 modelos se riggean (auto-rig offline) y reproducen animaciones de locomoción (idle/caminar) según el movimiento.

Incluye como tarea fundacional **montar el proyecto Godot y conectar el MCP `godot-mcp`** (config validada contra el schema de opencode) para que el agente construya, ejecute y verifique el juego en el editor.

## Scope

**In scope**

- Proyecto Godot 4.7 con estructura de carpetas, renderer y `project.godot`.
- Conexión del MCP `godot-mcp` (`@yanhuifair/godot-mcp`) a opencode + instalación del plugin del editor.
- Importación de los 3 GLB de Ancleto como escenas/recursos.
- Riggeo de los 3 modelos (auto-rig offline) e importación de los GLB riggeados.
- Animaciones de locomoción (idle/caminar) reproducidas según el estado de movimiento.
- Generación procedural de laberintos con conectividad garantizada y colocación de tazas, enemigos y spawn.
- Jugador `CharacterBody3D` con movimiento libre relativo a la cámara (`move_and_slide`), colisión con muros y cámara en tercera persona.
- Tazas de café recolectables, contador y condición de victoria de nivel.
- 1 enemigo inicial (escalando hasta 3) con IA de persecución y daño por contacto.
- Sistema de vidas, niveles, Game Over y reinicio.
- Pantalla de selección de las 3 variantes de Ancleto.
- HUD (tazas · vidas · nivel).
- Assets gratuitos **CC0** para muros, taza de café, enemigos y UI.

**Out of scope**

- Power-ups de café (modo "asustado"/comer enemigos).
- Múltiples personalidades de enemigos (emboscada, errático, patrulla) y fases scatter/chase.
- Animación de comer/daño/muerte (solo idle + caminar en el MVP).
- Audio/música pulidos, menús elaborados, portales/túneles y puntaje por combos.
- Afinado fino de dificultad y balance de largo plazo.

## Risks

- **Riggeo automático imperfecto**: el auto-rig de mallas estáticas (p. ej. skintokens.cpp) es experimental y puede producir topologías de huesos no ideales o deformación con *bleeding*. Mitigación: revisar esqueleto y deformación visualmente, usar `--postprocess`/`--geometric`; plan B: riggear en Mixamo (gratis, manual); fallback final: animación procedural si el rig falla.
- **Movimiento libre + IA continua**: la persecución necesita navegación válida sobre un mapa generado. Mitigación: `NavigationRegion3D` con bake de navmesh en runtime tras generar el mapa, con *fallback* a steering + evitación de muros si el bake falla.
- **Laberintos procedurales injugables**: zonas selladas o densidad de enemigos excesiva. Mitigación: validar conectividad por flood-fill tras generar y descartar/reintentar el mapa; colocar enemigos solo en celdas alcanzables y lejos del spawn.
- **Escasez de assets CC0 con "feel Pacman"**: no existe un kit de laberinto Pacman listo. Mitigación: muros modulares (Kenney) ensamblados proceduralmente + taza de Poly Pizza/Kenney; si falta algo, generar un mesh simple en el editor.
- **Scope creep de un género engañosamente simple**: Pacman arrastra mucho estado. Mitigación: el alcance MVP de arriba está congelado; todo lo demás queda explícitamente fuera.
- **El MCP puede fallar al arrancar** por el timeout de descubrimiento de 5 s con muchos tools. Mitigación: `timeout: 30000` en la config (ya validado contra el schema de opencode).

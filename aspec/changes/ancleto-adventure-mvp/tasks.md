# Tasks: Ancleto's Adventure — MVP estilo Pacman

## Fase 0 — Fundación (proyecto Godot + MCP)

- [x] 0.1 Crear `project.godot` con Godot 4.7 (nombre "Ancleto's Adventure", renderer Forward+, `application/run/main_scene`) y la estructura de carpetas de `design.md`.
- [x] 0.2 Configurar el mapa de entrada: acciones `move_up/move_down/move_left/move_right` (WASD + flechas) + `ui_confirm`, `ui_select_variant_next/prev`.
- [x] 0.3 Conectar el MCP `godot-mcp` (`@yanhuifair/godot-mcp`) en `~/.config/opencode/opencode.jsonc` con `timeout: 30000`. _(Los tools `godot-mcp_*` aparecen tras reiniciar opencode.)_
- [x] 0.4 Instalar el plugin del editor: `npx @yanhuifair/godot-mcp --enable-plugin -p .` (genera `addons/godot-mcp/`).
- [x] 0.5 Importar `Ancleto1/2/3.glb` a `res://assets/models/` y verificar que cargan sin errores.
- [x] 0.6 Verificación: `get_status` del MCP responde (386 tools) y el proyecto abre sin errores.

## Fase 1 — Generación procedural del laberinto

- [x] 1.1 Crear `resources/maze_config.tres` (tamaño 15×15, semilla, densidad de enemigos, braid ratio).
- [x] 1.2 Implementar `scripts/maze_generator.gd`: rejilla + *recursive backtracker* con `RandomNumberGenerator`.
- [x] 1.3 Añadir *braid* (eliminar ~60% de callejones sin salida) para crear bucles.
- [x] 1.4 Añadir validación por **flood-fill** con reintento por semilla (`generate_with_retry`); expone `bool`.
- [x] 1.5 Instanciar piso y muros sobre celdas sólidas dentro de `World.tscn` (`_build_maze`).
- [x] 1.6 Colocar tazas en todas las celdas abiertas salvo spawn y registrar spawns de enemigos alcanzables a distancia ≥ D.
- [x] 1.7 Construir `NavigationRegion3D` y `bake_navigation_mesh()` en runtime (desde colisiones); loguea si falla.
- [x] 1.8 Verificación: test headless genera 100 mapas → 0 fallos de conectividad (`tools/test_maze.gd`).

## Fase 2 — Jugador y cámara

- [x] 2.1 Crear `scenes/player/Player.tscn` (`CharacterBody3D` + `CapsuleShape3D` + `ModelPivot`).
- [x] 2.2 Implementar `scripts/player.gd`: `Input.get_vector` + `move_and_slide()` en el plano XZ, velocidad exportada.
- [x] 2.3 Añadir `Camera3D` cenital ortográfica encuadrando los límites del mapa (`_build_camera`). _(reemplazada en la Fase 9 por cámara en tercera persona)_
- [x] 2.4 Animación procedural: bob vertical + inclinación al girar (sin rig).
- [x] 2.5 Verificación: movimiento en 4 direcciones, colisión con muros y encuadre (test_world/flow + captura).

## Fase 3 — Tazas de café y condición de victoria

- [x] 3.1 Crear `scenes/pickups/CoffeeCup.tscn` (`Area3D` en capa 4 + modelo CC0).
- [x] 3.2 Implementar `scripts/coffee_cup.gd`: al entrar el jugador, emite recogida y se libera.
- [x] 3.3 `GameManager`: contador `cups_remaining`, señal `cups_changed(n)` y `level_cleared` al llegar a 0.
- [x] 3.4 Verificación: recoger taza decrementa; la última dispara `level_cleared` y regenera mapa (test_gameplay).

## Fase 4 — Enemigos y vidas

- [x] 4.1 Crear `scenes/enemies/Enemy.tscn` (`CharacterBody3D` + `NavigationAgent3D` + `Area3D` de daño en capa 3).
- [x] 4.2 Implementar `scripts/enemy.gd`: perseguir vía `NavigationAgent3D` (con *fallback* steering si no hay navmesh).
- [x] 4.3 Contacto enemigo→jugador llama a `GameManager.damage_player()` con invulnerabilidad (~1.5 s) y respawn en el spawn.
- [x] 4.4 Escalado por nivel: cantidad `min(1 + nivel - 1, 3)` y velocidad suave.
- [x] 4.5 `GameManager`: `lives` (3), señal `lives_changed(n)` y `game_over` al llegar a 0.
- [x] 4.6 Verificación: el enemigo persigue; el contacto quita vida; a 0 vidas se dispara `game_over` (test_gameplay).

## Fase 5 — Selección de personaje

- [x] 5.1 Crear `scenes/CharacterSelect.tscn` con los 3 modelos de Ancleto visibles y seleccionables.
- [x] 5.2 Implementar `scripts/character_select.gd`: guarda `GameManager.selected_variant` (0..2) y continúa al juego.
- [x] 5.3 `Player.tscn` instancia la variante elegida bajo `ModelPivot`.
- [x] 5.4 Verificación: elegir variante 2 arranca con el modelo `Ancleto2` (test_flow).

## Fase 6 — HUD y flujo de juego

- [x] 6.1 Crear `HUD` (CanvasLayer) con etiquetas de tazas, vidas y nivel, conectadas a las señales de `GameManager`.
- [x] 6.2 Crear `scenes/Main.tscn` como máquina de estados de pantalla: `CharacterSelect → World → GameOver`.
- [x] 6.3 Crear `scenes/GameOver.tscn` con reinicio (vidas=3, nivel=1, nuevo mapa).
- [x] 6.4 Verificación: HUD refleja cambios; ganar sube nivel; perder muestra Game Over y reiniciar funciona (test_flow).

## Fase 7 — Assets gratuitos (CC0)

- [x] 7.1 Taza de café 3D CC0 (Kenney, Poly Pizza) importada e integrada.
- [x] 7.2 Muros: **desviación** — se generan proceduralmente (cajas) en vez de un kit CC0 de Kenney; logra el objetivo sin placeholders grises.
- [x] 7.3 Modelo de enemigo CC0 (Slime de Quaternius) integrado con su animación.
- [x] 7.4 UI tematizada: **desviación** — panel y labels con estilo procedural (`StyleBoxFlat` + colores), en vez del Kenney UI Pack; sin tema gris por defecto.
- [x] 7.5 Verificación: el juego se ve coherente; licencias CC0 documentadas en `assets/CREDITS.md`.

## Fase 8 — Verificación final

- [x] 8.1 Playtest completo (headless): selección → jugar → recoger todas las tazas → nuevo mapa → perder vidas → Game Over → reiniciar.
- [x] 8.2 Cero errores en el debugger durante los tests (test_world / test_gameplay / test_flow).
- [x] 8.3 Captura del viewport con render real (Vulkan/Forward+, RX 6600): `shots/world.png`.

## Fase 9 — Tercera persona 3D (corrección visual)

- [x] 9.1 `Player.tscn`: `CameraPivot` → `SpringArm3D` → `Camera3D` (cámara en tercera persona).
- [x] 9.2 `player.gd`: mouse look (yaw/pitch con captura de mouse, `Escape` libera) + movimiento **relativo a la cámara** + rotación hacia el movimiento.
- [x] 9.3 `world.gd`: quitada la cámara cenital; celdas de **3 u** (`CELL_SIZE`) y muros de **3 u** de alto.
- [x] 9.4 Navmesh/colisiones ajustadas a la nueva escala (navpolys subió de ~130 a ~430).
- [x] 9.5 Verificación: captura en 3ª persona (`shots/world.png`, Ancleto de espaldas en corredor 3D) + tests headless sin errores.

## Fase 10 — Riggeo y animación de Ancleto

- [x] 10.1 Conservar las fuentes: GLB originales en `assets/models/source/AncletoN.glb`.
- [x] 10.2 Instalar **skintokens.cpp** (build C++23 + pesos F16 ~1.25 GB; corre en Vulkan sobre la RX 6600).
- [x] 10.3 Riggear los 3 modelos → `assets/models/AncletoN.glb` (los 3 con 28 huesos, skinning limpio validado).
- [x] 10.4 **Desviación**: locomoción **procedural** (`rig_pose.gd`) en vez de clips externos — skintokens no genera motion y no hay librería de clips compatible (SOMA30/Mixamo52) sin navegador.
- [x] 10.5 `player.gd` + `character_select.gd`: `RigPose.apply` reproduce caminar (con input) e idle (brazos abajo); bob procedural eliminado.
- [x] 10.6 Verificación: las 3 variantes caminan sin T-pose (`shots/world_v0.png`, `world_v1.png`, `world.png`) + tests headless verdes.

## Fase 11 — Pipeline de exportación (binarios por SO)

- [x] 11.1 Instalar los export templates de Godot 4.7.2 (`~/.local/share/godot/export_templates/4.7.2.stable/`).
- [x] 11.2 `export_presets.cfg` con presets: **Linux, Windows Desktop, macOS, Web, Android, iOS**.
- [x] 11.3 Script `tools/export_all.sh` (exporta cada preset a `build/<os>/`) + workflow `.github/workflows/export.yml`.
- [x] 11.4 Construidos en Linux: **Linux (71M), Windows (105M), macOS ad-hoc (111M), Web** (`.wasm`+`.pck`). Android necesita Android SDK + JDK; iOS necesita macOS + Xcode (documentado en el script).
- [x] 11.5 Verificación: binarios en `build/`; el binario de Linux arranca headless sin errores.

## Fase 12 — Entrega (ÚLTIMA tarea, solo tras el primer MVP)

- [ ] 12.1 `git init` en el proyecto y remoto `git@github.com:AncletoCEO/Ancleto-s-Adventure.git`.
- [ ] 12.2 `.gitignore` (ignorar `.godot/`, `shots/`, `build/`; conservar `*.import` y assets).
- [ ] 12.3 Commit inicial del MVP completo (incluye riggeo y pipeline) y `git push -u origin main`.

> **Tracker final**: la Fase 12 es la última. No se sube nada hasta que el primer MVP (Fases 0–11) esté terminado.

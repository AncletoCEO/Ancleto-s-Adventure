# Design: Ancleto's Adventure — MVP estilo Pacman

## Approach

Proyecto Godot 4.7 *greenfield*, renderer **Forward+** (el equipo tiene GPU AMD con Vulkan 1.4). El juego es **3D en tercera persona**: los muros y el piso son geometría 3D real, la cámara sigue a Ancleto desde atrás con **mouse look** y el movimiento es **libre** relativo a la cámara (sin ajuste a rejilla).

Piezas centrales:

- **Generación procedural determinista y validada**: un laberinto de celdas impares se excava con *recursive backtracker*, se "desramifica" (braid: se eliminan callejones sin salida) para acercarse al feel de Pacman, y se **valida por flood-fill** que toda celda abierta sea alcanzable desde el spawn. Si falla, se reintenta con otra semilla.
- **Navegación en runtime**: tras generar, se hornea (`bake_navigation_mesh()`) la `NavigationRegion3D` del laberinto para que los enemigos persigan con `NavigationAgent3D`. Si el bake falla, *fallback* a steering directo + evitación de muros.
- **Estado centralizado** en un autoload `GameManager` (vidas, nivel, tazas restantes, variante elegida) que emite señales; los nodos de escena reaccionan. Mantiene el flujo desacoplado y verificable.
- **Selección de variante**: la elección del jugador se guarda en `GameManager` y el jugador instancia la escena GLB correspondiente bajo un pivote, sin duplicar lógica de movimiento.

## Architecture

### Estructura de carpetas

```
res://
├── project.godot
├── addons/godot-mcp/                 # plugin del MCP (tarea 0)
├── scenes/
│   ├── Main.tscn                     # escena principal (máquina de estados de pantalla)
│   ├── CharacterSelect.tscn
│   ├── GameOver.tscn
│   ├── level/World.tscn              # contenedor del nivel jugable
│   ├── player/Player.tscn
│   ├── enemies/Enemy.tscn
│   └── pickups/CoffeeCup.tscn
├── scripts/
│   ├── game_manager.gd               # Autoload
│   ├── maze_generator.gd
│   ├── player.gd
│   ├── enemy.gd
│   ├── coffee_cup.gd
│   ├── hud.gd
│   └── character_select.gd
├── assets/
│   ├── models/  (Ancleto1/2/3.glb, enemigo, taza, muros)
│   ├── materials/
│   ├── audio/
│   └── ui/
└── resources/
    └── maze_config.tres              # tamaño, densidad de tazas/enemigos
```

### Árbol de escena (runtime)

```
Main (Node)                       ← controla pantallas (select → juego → gameover)
└── World (Node3D)
    ├── GameManager              (Autoload, fuera del árbol visible)
    ├── Maze (Node3D)            ← generado por maze_generator.gd
    │   ├── Floor (MeshInstance3D + StaticBody3D)
    │   ├── Walls (Node3D)       ← instancias de muro modular sobre celdas sólidas
    │   ├── CoffeeCups (Node3D)  ← grupo "coffee"
    │   ├── EnemySpawns (Node3D) ← marcadores
    │   └── NavigationRegion3D   ← navmesh horneado en runtime
    ├── Player (CharacterBody3D) ← Player.tscn
    │   ├── ModelPivot (Node3D)  ← aquí se instancia la variante GLB elegida
    │   ├── CollisionShape3D (CapsuleShape3D)
    │   └── CameraPivot (Node3D) → SpringArm3D → Camera3D (3ª persona, mouse look)
    ├── Enemies (Node3D)
    │   └── Enemy ×N (CharacterBody3D + NavigationAgent3D + Area3D de daño)
    └── HUD (CanvasLayer)
        └── Labels (tazas · vidas · nivel)
```

### Generador de laberinto (`maze_generator.gd`)

1. Rejilla de `W×H` celdas (por defecto **15×15**, dimensiones impares). Todo muro al inicio.
2. *Recursive backtracker* con semilla (`RandomNumberGenerator`) para tallar pasillos de 1 celda.
3. **Braid**: eliminar una fracción de callejones sin salida (p. ej. ~60%) para crear bucles → recorrido más "Pacman".
4. **Validación por flood-fill** desde el spawn: si alguna celda abierta queda inalcanzable, reintentar con nueva semilla (máx. N intentos).
5. Colocación: tazas en **todas** las celdas abiertas salvo el spawn; spawn del jugador en una esquina abierta; spawns de enemigos en celdas alcanzables a distancia ≥ D del jugador.
6. Instanciar muros modulares sobre celdas sólidas y construir `NavigationRegion3D` sobre la superficie caminable; `bake_navigation_mesh()`.

### Movimiento y cámara (tercera persona)

- `Player.gd`: lee `Input.get_vector(...)`, transforma la dirección por el *yaw* de la cámara (movimiento **relativo a la cámara**) y aplica `move_and_slide()` en el plano XZ. Ancleto rota hacia la dirección de movimiento.
- **Cámara 3ª persona con mouse look**: `CameraPivot` (yaw, gira con el mouse en X) → `SpringArm3D` (pitch con el mouse en Y, `length ≈ 5`, `collision_mask = 1`) → `Camera3D`. El SpringArm se acorta al chocar con muros. Mouse capturado; `Escape` lo libera.
- Celdas de **3 u** (pasillos más anchos para que la cámara respire); muros de **3 u** de alto.
- Colisión por capas: `1 = world` (muros/piso), `2 = player`, `3 = enemy`, `4 = pickup`.

### Enemigos (`enemy.gd`)

- `NavigationAgent3D` con `target_position` = posición del jugador, actualizado en `_physics_process`.
- Contacto: `Area3D` del enemigo contra el `CharacterBody3D` del jugador → `GameManager.damage_player()` con ventana de invulnerabilidad (p. ej. 1.5 s) y *respawn* del jugador en el spawn.
- Cantidad por nivel: `min(1 + nivel - 1, 3)`; velocidad escalada suavemente.

### Estado y flujo (`game_manager.gd`, Autoload)

```
señales: cups_changed(n) · lives_changed(n) · level_changed(n) · game_over · level_cleared
estado:  lives (3) · level (1) · cups_remaining · selected_variant (0..2)
```

Flujo: `CharacterSelect` → `World` (genera nivel) → al recoger la última taza `level_cleared` → regenera mapa, `level += 1` → si `lives == 0`, `game_over` → `GameOver` → reinicio.

### Variantes de Ancleto

`character_select.gd` presenta los 3 modelos; la elección se guarda en `GameManager.selected_variant`. `Player.tscn` instancia el GLB **riggeado** correspondiente bajo `ModelPivot`.

### Riggeo y animación (offline)

Los 3 modelos son mallas estáticas; se riggean **offline** antes de importarlos:

1. **Auto-rig**: `skintokens-cli rig <pesos> source.glb rigged.glb --device vulkan --postprocess` (skin-tokens.cpp; CPU/Vulkan, varios minutos por malla, **experimental** → revisar huesos y deformación). Plan B: **Mixamo** (auto-rig + clips, gratis, manual). Se conservan fuente y salida separadas: `assets/models/source/AncletoN.glb` → `assets/models/AncletoN.glb`.
2. **Animación**: obtener clips `idle`/`walk` (retarget desde un esqueleto humanoide, o `generate-motion`/`text-to-motion`) e importarlos a un `AnimationPlayer`.
3. **Wiring**: `player.gd` reproduce `walk` mientras hay input de movimiento e `idle` al detenerse; se elimina el bob procedural. El `ModelPivot` sigue rotando hacia el movimiento.

## Validation

- **Conectividad del mapa**: aserción automática — flood-fill desde el spawn debe alcanzar todas las celdas con taza; en modo test se generan N mapas y se exige 100% de éxito. Se ejecuta vía un script de test en Godot headless (`godot --headless -s`) y/o desde el MCP.
- **Parseo de scripts**: `godot --headless --check-only` (o la validación del MCP) sobre cada `.gd` antes de dar una tarea por hecha.
- **Playtest en el editor**: ejecutar el proyecto, recorrer el mapa, recoger tazas, dejarse tocar por un enemigo (pierde vida), limpiar el nivel (nuevo mapa) y agotar vidas (Game Over). Verificado con el output de debug y **capturas** del viewport vía `godot-mcp`.
- **Criterio de hecho por tarea**: la tarea está lista cuando el juego arranca sin errores en el debugger y el comportamiento observable coincide con el `Scenario` de la spec correspondiente.

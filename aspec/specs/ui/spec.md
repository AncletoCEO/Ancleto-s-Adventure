# Spec: Interfaz y flujo de pantallas

## Requirements

### Requirement: Selección de personaje

El sistema SHALL permitir elegir entre las 3 variantes de Ancleto antes de jugar.

#### Scenario: Elegir variante

- **WHEN** la pantalla de selección muestra las 3 variantes
- **THEN** al elegir una se fija esa variante y comienza el juego con ese modelo

### Requirement: HUD de estado

El sistema SHALL mostrar en pantalla el estado de la partida.

#### Scenario: Reflejo de cambios de estado

- **WHEN** cambian las tazas restantes, las vidas o el nivel
- **THEN** el HUD se actualiza con los nuevos valores

### Requirement: Reinicio de partida

El sistema SHALL permitir reiniciar tras un fin de partida.

#### Scenario: Reiniciar tras Game Over

- **WHEN** el jugador reinicia desde la pantalla de Game Over
- **THEN** las vidas vuelven a 3, el nivel a 1 y se genera un mapa procedural nuevo

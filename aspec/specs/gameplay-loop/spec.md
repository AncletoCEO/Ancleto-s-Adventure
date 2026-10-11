# Spec: Bucle de juego

## Requirements

### Requirement: Recolección de tazas de café

El jugador SHALL poder recoger las tazas de café dispersas por el mapa.

#### Scenario: Recoger una taza

- **WHEN** Ancleto entra en contacto con una taza
- **THEN** la taza desaparece del mapa y el contador de tazas restantes disminuye en uno

### Requirement: Victoria de nivel

El sistema SHALL completar el nivel cuando se recogen todas las tazas.

#### Scenario: Todas las tazas recogidas

- **WHEN** el contador de tazas restantes llega a cero
- **THEN** se genera un nuevo mapa procedural y el nivel aumenta en uno

### Requirement: Persecución de enemigos

Los enemigos SHALL perseguir al jugador.

#### Scenario: Perseguir al jugador

- **WHEN** un enemigo tiene navegación válida hacia el jugador
- **THEN** se mueve de forma continua hacia la posición actual del jugador

### Requirement: Daño y sistema de vidas

El sistema SHALL aplicar daño al jugador por contacto con enemigos y llevar el conteo de vidas.

#### Scenario: Contacto con enemigo

- **WHEN** un enemigo toca a Ancleto y Ancleto no está en periodo de invulnerabilidad
- **THEN** Ancleto pierde una vida, obtiene invulnerabilidad temporal y reaparece en el spawn

#### Scenario: Fin de partida

- **WHEN** las vidas del jugador llegan a cero
- **THEN** se dispara el evento de fin de partida y se muestra la pantalla de Game Over

### Requirement: Escalado de dificultad

El sistema SHALL aumentar la cantidad de enemigos con el nivel, hasta un techo.

#### Scenario: Más enemigos por nivel

- **WHEN** el nivel aumenta
- **THEN** la cantidad de enemigos es `min(1 + nivel - 1, 3)`

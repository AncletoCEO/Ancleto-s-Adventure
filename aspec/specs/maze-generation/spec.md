# Spec: Generación procedural del laberinto

## Requirements

### Requirement: Generación procedural de laberinto

El sistema SHALL generar un laberinto nuevo y jugable en cada nivel mediante un algoritmo procedural determinista a partir de una semilla.

#### Scenario: Mapa conectado

- **WHEN** se genera un nivel
- **THEN** todas las celdas abiertas son alcanzables desde el spawn del jugador (verificado por flood-fill)

#### Scenario: Reintento por mapa inválido

- **WHEN** la validación detecta celdas abiertas inalcanzables
- **THEN** el generador descarta el mapa y reintenta con otra semilla hasta lograr conectividad o agotar el máximo de intentos

### Requirement: Colocación de contenido sobre el mapa

El sistema SHALL colocar las tazas de café y los puntos de aparición de enemigos sobre celdas alcanzables del laberinto.

#### Scenario: Tazas alcanzables

- **WHEN** el mapa termina de generarse
- **THEN** cada taza ocupa una celda alcanzable y existe al menos una taza

#### Scenario: Enemigos lejos del spawn

- **WHEN** se colocan los enemigos
- **THEN** cada enemigo aparece en una celda alcanzable a una distancia mínima `D` del spawn del jugador

### Requirement: Navegación del mapa generado

El sistema SHALL proveer navegación válida a los enemigos sobre el mapa generado.

#### Scenario: Navmesh horneado

- **WHEN** el mapa termina de generarse
- **THEN** se hornea la malla de navegación y los agentes pueden trazar rutas hacia el jugador

#### Scenario: Fallback sin navmesh

- **WHEN** el horneado de la malla de navegación falla
- **THEN** los enemigos usan persecución por dirección directa con evitación de muros

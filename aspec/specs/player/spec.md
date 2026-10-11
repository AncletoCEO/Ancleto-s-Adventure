# Spec: Jugador y cámara

## Requirements

### Requirement: Movimiento libre relativo a la cámara en 3D

El jugador SHALL controlar a Ancleto con movimiento libre relativo a la orientación de la cámara, sin ajuste a rejilla.

#### Scenario: Moverse en las cuatro direcciones

- **WHEN** el jugador mantiene pulsada una dirección de movimiento
- **THEN** Ancleto se desplaza de forma continua en esa dirección **relativa a la cámara** y rota hacia su dirección de movimiento

#### Scenario: Colisión con muros

- **WHEN** Ancleto avanza contra un muro
- **THEN** se detiene o desliza contra él sin atravesarlo

### Requirement: Cámara en tercera persona

El sistema SHALL seguir a Ancleto con una cámara en tercera persona controlable con el mouse.

#### Scenario: Seguir al jugador

- **WHEN** Ancleto se mueve por el nivel
- **THEN** la cámara lo sigue desde atrás a una distancia fija, acortándose si un muro se interpone

#### Scenario: Girar la cámara con el mouse

- **WHEN** el jugador mueve el mouse
- **THEN** la cámara rota (yaw con el eje X, pitch con el eje Y) alrededor de Ancleto

### Requirement: Variante de Ancleto seleccionada

El jugador SHALL mostrar el modelo de la variante elegida.

#### Scenario: Modelo correcto en juego

- **WHEN** el jugador elige una de las 3 variantes
- **THEN** el modelo GLB correspondiente aparece como Ancleto en el nivel

### Requirement: Animación de locomoción

El jugador SHALL mostrar a Ancleto riggeado con animaciones ligadas a su estado de movimiento.

#### Scenario: Caminar

- **WHEN** Ancleto se desplaza
- **THEN** reproduce la animación de caminar

#### Scenario: Reposo

- **WHEN** Ancleto se detiene
- **THEN** reproduce la animación de reposo (idle)

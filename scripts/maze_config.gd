class_name MazeConfig
extends Resource

## Parámetros de generación del laberinto y colocación de contenido.

@export var width: int = 15
@export var height: int = 15
@export_range(0.0, 1.0) var braid_ratio: float = 0.6
@export var min_enemy_distance: int = 5
@export var base_seed: int = 0

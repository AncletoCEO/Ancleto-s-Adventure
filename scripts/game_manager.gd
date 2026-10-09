extends Node

## Estado global de la partida (Autoload "GameManager").

signal cups_changed(remaining: int)
signal lives_changed(lives: int)
signal level_changed(level: int)
signal game_over
signal level_cleared

const START_LIVES := 3
const MAX_ENEMIES := 3

var lives: int = START_LIVES
var level: int = 1
var cups_remaining: int = 0
var selected_variant: int = 0

var player: Node3D = null
var world: Node3D = null


func reset() -> void:
	lives = START_LIVES
	level = 1
	selected_variant = 0
	cups_remaining = 0


func set_cups(n: int) -> void:
	cups_remaining = n
	cups_changed.emit(cups_remaining)


func collect_cup() -> void:
	cups_remaining = max(0, cups_remaining - 1)
	cups_changed.emit(cups_remaining)
	if cups_remaining == 0:
		level_cleared.emit()


func enemy_count() -> int:
	return min(1 + level - 1, MAX_ENEMIES)


func advance_level() -> void:
	level += 1
	level_changed.emit(level)


func damage_player() -> void:
	if lives <= 0:
		return
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()

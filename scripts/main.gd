extends Node

## Máquina de estados de pantallas: CharacterSelect → World → GameOver.

const SELECT_SCENE := preload("res://scenes/CharacterSelect.tscn")
const WORLD_SCENE := preload("res://scenes/World.tscn")
const GAMEOVER_SCENE := preload("res://scenes/GameOver.tscn")

var _current: Node = null


func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)
	_show(SELECT_SCENE)


func _show(scene: PackedScene) -> void:
	if _current:
		remove_child(_current)
		_current.queue_free()
		_current = null
	_current = scene.instantiate()
	add_child(_current)
	if _current.has_signal("confirmed"):
		_current.confirmed.connect(_start_game)
	if _current.has_signal("restart"):
		_current.restart.connect(_on_restart)


func _start_game() -> void:
	_show(WORLD_SCENE)


func _on_game_over() -> void:
	_show(GAMEOVER_SCENE)


func _on_restart() -> void:
	GameManager.reset()
	_start_game()

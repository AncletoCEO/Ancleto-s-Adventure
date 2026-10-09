extends Control

## Pantalla de fin de partida con reinicio.

signal restart

var _label: Label


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(box)
	var title := Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_label)
	var hint := Label.new()
	hint.text = "Enter / Espacio para reiniciar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)
	_label.text = "Llegaste al nivel %d" % GameManager.level


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_confirm"):
		restart.emit()

extends CanvasLayer

## HUD: tazas restantes, vidas y nivel, conectado a las señales de GameManager.

var cups_label: Label
var lives_label: Label
var level_label: Label


func _ready() -> void:
	_build_ui()
	GameManager.cups_changed.connect(_on_changed)
	GameManager.lives_changed.connect(_on_changed)
	GameManager.level_changed.connect(_on_changed)
	_refresh()


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 16)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.12, 0.85)
	style.border_color = Color(0.35, 0.55, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	cups_label = _make_label(Color(0.95, 0.82, 0.4))
	lives_label = _make_label(Color(0.95, 0.42, 0.45))
	level_label = _make_label(Color(0.75, 0.85, 1.0))
	box.add_child(cups_label)
	box.add_child(lives_label)
	box.add_child(level_label)


func _make_label(color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", color)
	return l


func _on_changed(_value: int) -> void:
	_refresh()


func _refresh() -> void:
	if cups_label:
		cups_label.text = "Tazas: %d" % GameManager.cups_remaining
	if lives_label:
		lives_label.text = "Vidas: %d" % GameManager.lives
	if level_label:
		level_label.text = "Nivel: %d" % GameManager.level

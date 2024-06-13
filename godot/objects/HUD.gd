extends CanvasLayer

@export var map: TileMap

var hud_visible: bool = true

@onready var panel: Panel = $Panel
@onready var menuToggleBtn: Button = $Panel/Button
@onready var distSlider: HSlider = $Panel/MarginContainer/VBoxContainer/HBoxContainer/HSlider

func _ready() -> void:
	if not map:
		push_warning("No Tilemap Selected\nDisabling HUD!")
		toggle_visibility()
		return
	
	distSlider.set_value_no_signal(map.view_distance)
	menuToggleBtn.connect("pressed", _on_menuToggleBtn_pressed)
	distSlider.connect("value_changed", _on_distSlider_input)

func toggle_visibility() -> void:
	if hud_visible:
		var tween = get_tree().create_tween()
		menuToggleBtn.text = "<"
		tween.tween_property(panel, "position:x", 1152, 0.5).set_trans(Tween.TRANS_SINE)
	else:
		var tween = get_tree().create_tween()
		menuToggleBtn.text = ">"
		tween.tween_property(panel, "position:x", 808, 0.5).set_trans(Tween.TRANS_SINE)
	
	hud_visible = !hud_visible

func _on_menuToggleBtn_pressed() -> void:
	toggle_visibility()

func _on_distSlider_input(value: float) -> void:
	var v: int = int(value)
	map.view_distance = v
	map.generate_world(map.CAMERA.get_target_position())

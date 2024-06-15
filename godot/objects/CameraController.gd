extends Camera2D

signal update_map(new_pos)

@export var SPEED: int = 500
@export var ZOOM_FACTOR: Vector2 = Vector2(0.5, 0.5)
@export var UPDATE_THRESHOLD: int = 64

var last_pos: Vector2 = Vector2.ZERO
var dragging: bool = false

func _ready() -> void:
	last_pos = self.get_target_position()

func _physics_process(delta: float) -> void:
	var input_vec: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	input_vec = input_vec.normalized()
	
	self.position += input_vec * SPEED * delta
	
	var delta_pos = self.get_target_position().distance_to(last_pos)
	if delta_pos >= UPDATE_THRESHOLD:
		last_pos = self.get_target_position()
		emit_signal("update_map", last_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if event.is_pressed():
					return
				# Zoom in
				self.zoom += ZOOM_FACTOR
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.is_pressed():
					return
				# Zoom Out
				var new_zoom = self.zoom - ZOOM_FACTOR
				if new_zoom.x <= 0 or new_zoom.y <= 0:
					return
				
				self.zoom -= ZOOM_FACTOR
			MOUSE_BUTTON_LEFT:
				if event.is_pressed() and not dragging:
					dragging = true
				else:
					dragging = false
	
	if event is InputEventMouseMotion:
		if dragging:
			self.global_position += event.relative * -1

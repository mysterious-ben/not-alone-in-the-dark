class_name Hero extends CharacterBody2D

@export var move_speed: float = 40.0
@export var back_speed: float = 20.0
@export var walk_animation_speed: float = 3.0
@export var flashlight_on: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: Node2D = $Flashlight
@onready var flashlight_position: Vector2 = flashlight.position
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D
@onready var action_finder: Area2D = $ActionFinder

var is_dead: bool = false
var is_in_dialogue: bool = false
var look_vector: Vector2 = Vector2(1.0, 0)
var look_direction: float = 1.0
# The body moves by fractions of a pixel. Sprites snap to the pixel grid, lights don't, so the
# flashlight drifted against the world and flickered. Visual children are drawn at whole-pixel
# positions instead: they're top-level, opt out of built-in physics interpolation and follow the
# body's position interpolated by hand.
var previous_position: Vector2
var visual_positions: Dictionary[Node2D, Vector2] = {}
signal died


func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	died.emit()
	sprite.play("hurt")
	await sprite.animation_finished
	queue_free()


func _ready() -> void:
	previous_position = global_position
	for child: Node in get_children():
		if child is Node2D and not (
			child is CollisionObject2D or child is CollisionPolygon2D or child is CollisionShape2D
		):
			var node: Node2D = child
			visual_positions[node] = node.position
			node.top_level = true
			node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	sprite.sprite_frames.set_animation_speed("walk", walk_animation_speed)
	sprite.sprite_frames.set_animation_speed("walk_flashlight", walk_animation_speed)


func _process(_delta: float) -> void:
	var fraction: float = Engine.get_physics_interpolation_fraction()
	var visual_position: Vector2 = previous_position.lerp(global_position, fraction).round()
	for node: Node2D in visual_positions:
		node.global_position = visual_position + visual_positions[node]


func _unhandled_input(event: InputEvent) -> void:
	if is_dead or is_in_dialogue:
		return
	if event.is_action_pressed("activate"):
		var nearest: DialogueActionable2D = null
		var nearest_distance: float = INF
		for area: Area2D in action_finder.get_overlapping_areas():
			var distance: float = area.global_position.distance_squared_to(global_position)
			if area is DialogueActionable2D and distance < nearest_distance:
				nearest_distance = distance
				nearest = area
		if nearest:
			get_viewport().set_input_as_handled()
			nearest.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
			is_in_dialogue = true
			nearest.action()
			# the whole game freezes while talking; only the balloon keeps running
			# nearest.dialogue_balloon.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_dialogue_ended() -> void:
	is_in_dialogue = false
	# get_tree().paused = false


func _physics_process(delta: float) -> void:
	previous_position = global_position
	if is_dead or is_in_dialogue:
		return

	var look_vector_upd: Vector2 = Input.get_vector(
		"look_left",
		"look_right",
		"look_down",
		"look_up",
	)
	if abs(look_vector_upd.x) > 0:
		if look_vector_upd.x > 0:
			look_direction = 1.0
		elif look_vector_upd.x < 0:
			look_direction = -1.0
		look_vector = look_vector_upd

	if look_direction > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	# reach in front of the hero, mirrored around the sprite's center like flip_h does
	action_finder.scale.x = look_direction
	var flashlight_rotation: float = 0.0 if look_direction > 0 else PI
	if flashlight.rotation != flashlight_rotation:
		flashlight.rotation = flashlight_rotation
		# keep the light source on the lens: mirror around the sprite's center like flip_h does
		visual_positions[flashlight].x = (
			visual_positions[sprite].x
			+ (flashlight_position.x - visual_positions[sprite].x) * look_direction
		)

	var move_direction: float = Input.get_axis("move_left", "move_right")

	var speed: float = 0.0
	if abs(move_direction) > 0:
		if (
			((move_direction > 0) and (look_direction > 0))
			or ((move_direction < 0) and (look_direction < 0))
		):
			speed = move_speed * move_direction
		else:
			speed = back_speed * move_direction

	sprite.speed_scale = 1.0
	if abs(speed) > 0:
		sprite.play("walk_flashlight")
		sprite.speed_scale = abs(speed) / move_speed
	else:
		sprite.play("idle_flashlight")

	velocity.x = speed

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

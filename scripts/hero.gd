class_name Hero extends CharacterBody2D

@export var move_speed: float = 40.0
@export var back_speed: float = 20.0
@export var walk_animation_speed: float = 3.0
@export var flashlight_on: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_dead: bool = false
var look_vector: Vector2 = Vector2(1.0, 0)
var look_direction: float = 1.0
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
	sprite.sprite_frames.set_animation_speed("walk", walk_animation_speed)
	sprite.sprite_frames.set_animation_speed("walk_flashlight", walk_animation_speed)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# if Input.is_action_just_pressed()
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

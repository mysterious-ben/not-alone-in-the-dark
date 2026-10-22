class_name Radio extends AnimatableBody2D

@onready var dialogue_actionable_2d: DialogueActionable2D = $DialogueActionable2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = $PointLight2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var dialogue_resource: DialogueResource
@export var dialogue_cue: String
@export var is_on: bool = false:
	set(value):
		is_on = value
		if is_node_ready():
			_apply_state()

func _ready() -> void:
	dialogue_actionable_2d.dialogue_resource = dialogue_resource
	dialogue_actionable_2d.dialogue_cue = dialogue_cue
	# without dialogue the radio is scenery: the hero's ActionFinder ignores unmonitorable areas,
	# otherwise it would wait forever for a dialogue that never starts
	dialogue_actionable_2d.monitorable = dialogue_resource != null and not dialogue_cue.is_empty()
	_apply_state()


func turn_on() -> void:
	is_on = true


func turn_off() -> void:
	is_on = false


func _apply_state() -> void:
	sprite.play("on" if is_on else "off")
	light.enabled = is_on
	audio.playing = is_on

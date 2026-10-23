class_name Radio extends AnimatableBody2D

@onready var dialogue_actionable_2d: DialogueActionable2D = $DialogueActionable2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = $PointLight2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var dialogue_resource: DialogueResource
@export var dialogue_cue: String

func _ready() -> void:
	dialogue_actionable_2d.dialogue_resource = dialogue_resource
	dialogue_actionable_2d.dialogue_cue = dialogue_cue
	_apply_state()


func turn_on() -> void:
	GameState.radio_on = true
	_apply_state()


func turn_off() -> void:
	GameState.radio_on = false
	_apply_state()


func _apply_state() -> void:
	sprite.play("on" if GameState.radio_on else "off")
	light.enabled = GameState.radio_on
	audio.playing = GameState.radio_on

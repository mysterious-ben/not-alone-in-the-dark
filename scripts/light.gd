class_name Light extends AnimatableBody2D

@export var dialogue_actionable_2d: DialogueActionable2D
@export var dialogue_resource: DialogueResource
@export var dialogue_cue: String

func _ready() -> void:
	dialogue_actionable_2d.dialogue_resource = dialogue_resource
	dialogue_actionable_2d.dialogue_cue = dialogue_cue

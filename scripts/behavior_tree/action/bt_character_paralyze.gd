class_name BTCharacterParalyze extends BTNode

@export var character: CharacterController
@export var paralyzed: bool = true
@export var stop_velocity: bool = true

func process(_delta: float) -> Status:
	if character:
		character.paralyzed = paralyzed
		if stop_velocity:
			character.set_idle_same_dir()
	return Status.SUCCESS

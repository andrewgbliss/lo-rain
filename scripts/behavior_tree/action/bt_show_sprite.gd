class_name BTShowSprite extends BTNode

@export var character: CharacterController
@export var show: bool = true

func process(_delta: float) -> Status:
	character.sprite.visible = show
	return Status.SUCCESS

class_name BTTextParserActive extends BTNode

@export var active: bool = true

func process(_delta: float) -> Status:
	TextParser.active = active
	return Status.SUCCESS

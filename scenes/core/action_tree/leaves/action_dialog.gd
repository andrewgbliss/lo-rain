class_name ActionDialog extends ActionLeaf

@export var messages: Array[String]

func run() -> void:
	for message in messages:
		DialogUi.dialog_text.send_message(message)
	await DialogUi.dialog_text.is_finished
	next()

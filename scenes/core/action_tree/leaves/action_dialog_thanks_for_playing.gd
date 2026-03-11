class_name ActionDialogThanksForPlaying extends ActionLeaf

@export var messages: Array[String] = [
  "Thanks for playing Rain Quest! Better luck next time. You can restart or restore your game from the menu, or press F7."
]

func run() -> void:
	for message in messages:
		DialogUi.dialog_text.send_message(message)
	await DialogUi.dialog_text.is_finished
	next()

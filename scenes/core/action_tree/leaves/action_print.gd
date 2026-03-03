class_name ActionPrint extends ActionLeaf

@export var message: String = "Hello, World!"

func run() -> void:
  print(message)
  next()

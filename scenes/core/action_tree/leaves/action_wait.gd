class_name ActionWait extends ActionLeaf

@export var duration: float = 1.0

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

func _on_timer_timeout() -> void:
	next()

func run() -> void:
	_timer.wait_time = duration
	_timer.start()

class_name BTHotspot extends Area2D

@export var nouns: Array[String]
@export var adjectives: Array[String]

@export_group("Behavior Trees")
@export var bt_on_load: BTPlayers
@export var bt_enter_player: BTPlayers
@export var on_enter_start: bool = false
@export var one_shot_enter: bool = false
@export var bt_exit_player: BTPlayers
@export var on_exit_start: bool = false
@export var one_shot_exit: bool = false

@export_group("Text Parser Actions")
@export var actions: Dictionary[String, BTPlayers]

var within_collider = false
var sprite
var did_one_shot_enter = false
var did_one_shot_exit = false

func _ready():
	did_one_shot_enter = false
	did_one_shot_exit = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if bt_on_load:
		bt_on_load.start()

func _on_body_entered(body):
	if body is CharacterController:
		within_collider = true
		if on_enter_start:
			if one_shot_enter:
				if did_one_shot_enter:
					return
				did_one_shot_enter = true
			if bt_enter_player:
				bt_enter_player.start()

func _on_body_exited(body):
	if body is CharacterController:
		within_collider = false
		if on_exit_start:
			if one_shot_exit:
				if did_one_shot_exit:
						return
				did_one_shot_exit = true
			if bt_exit_player:
				bt_exit_player.start()

func is_close_enough():
	return within_collider
		
func has_action(action: String):
	return actions.has(action)

func has_noun(a):
	return a in nouns

func has_adjective(a: String):
	return a in adjectives

func run_action(verb: String, object: String, command: String):
	if actions.has(verb):
		var bt_player = actions[verb]
		bt_player.blackboard.set_var("verb", verb)
		bt_player.blackboard.set_var("object", object)
		bt_player.blackboard.set_var("command", command)
		bt_player.start()

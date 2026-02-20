@tool

class_name Item extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var room_texture: Texture
@export var icon_texture: Texture
@export var inspect_texture: Texture

@export_tool_button("Add To Scene", "Callable") var add_to_scene_action = add_to_scene

func add_to_scene():
	var root = EditorInterface.get_edited_scene_root()
	if root:
		var sprite = Sprite2D.new()
		sprite.texture = room_texture
		root.add_child(sprite)
		sprite.name = "Sprite2D"
		sprite.owner = root

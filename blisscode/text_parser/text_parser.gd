extends Node

@export_group("Default Responses")
@export var DontUnderstand: String = "I don't understand what you mean."
@export var NotCloseEnough: String = "You aren't close enough."
@export var CantDoAction: String = "You can't do that."
@export var AlreadyOpen: String = "It's already open."
@export var AlreadyClosed: String = "It's already closed."
@export var MultipleHotspots: String = "Which one?"

var verb: String
var object: String
var sentence: PackedStringArray
var command_stack: Array
var history_index: int = 0

signal send_message(s: String)

func process_command(command: String):
	#	Clean up the command trim edges and lowercase
	var original_command = command.strip_edges(true, true).to_lower()

	# replace fuck with with fuck_with
	command = original_command.replace("fuck with", "fuck_with")
	#	Pop one off of the history to keep only 5 in the history
	if command_stack.size() > 5:
		command_stack.pop_front()
	
	#	If the command isnt in the history then put it in	
	if not command_stack.has(original_command):
		command_stack.push_back(original_command)
	
	#	If the command is blank then run the dont understand messages			
	if command == "":
		send_message.emit(DontUnderstand)
		return
		
	#	Remove any stop words
	command = remove_stopwords(command)
	command = remove_special_characters(command)
	
	#	Split the command into parts separated by space
	sentence = command.split(" ", false, 2)

	#	If there is nothing in the sentence then run the dont understand message
	if sentence.size() == 0:
		send_message.emit(DontUnderstand)
		return
	
	verb = ""
	object = ""
	parse_sentence()
		
	# print("Sentence: ", sentence)
	# print("Verb: ", verb)
	# print("Object: ", object)

	if verb == "quit":
		GameManager.quit()
		return

	if verb == "look":
		var room = find_room()
		if room:
			if object == "":
				object = "room"
			var closest_key = get_closest_key(room.descriptions.keys(), object)
			if room.descriptions and room.descriptions.has(closest_key):
				for s in room.descriptions[closest_key]:
					send_message.emit(s)
				return

	var hotspots = find_hotspots()

	if hotspots.size() > 0:
		var found_hotspot: Hotspot = null

		if hotspots.size() > 1:
			var has_action_hotspots: Array[Hotspot] = []
			for hotspot in hotspots:
				if hotspot.has_action(verb):
					has_action_hotspots.append(hotspot)

			if has_action_hotspots.size() == 1:
				found_hotspot = has_action_hotspots[0]
			else:
				var object_parts = object.split(" ", false)
				for hotspot in has_action_hotspots:
					for part in object_parts:
						if hotspot.has_adjectives(part):
							found_hotspot = hotspot
							break
					if found_hotspot:
						break

			if not found_hotspot:
				send_message.emit(MultipleHotspots)
				return
		else:
			found_hotspot = hotspots[0]


		if found_hotspot:
			if !found_hotspot.is_close_enough() and found_hotspot.has_action(verb):
				#	If they are not close enough to the hot spot, run the not close enough messages
				send_message.emit(NotCloseEnough)
				return
			elif found_hotspot.has_action(verb):
				found_hotspot.run_action(verb, object, command)
				return

	#	Cant parse the command 
	send_message.emit(DontUnderstand)
	
func parse_sentence():
	if sentence.size() == 1:
		verb = sentence[0]
	elif sentence.size() == 2:
		verb = sentence[0]
		object = sentence[1]
	elif sentence.size() > 2:
		verb = sentence[0]
		# For sentences with more than 2 words, the object is the rest of the array after index 0
		object = ""
		for i in range(1, sentence.size()):
			if i > 1:
				object += " "
			object += sentence[i]

		
func find_room() -> Room:
	var rooms = get_all_rooms()
	for room in rooms:
		if room.is_visible_in_tree():
			return room
	return null;

func find_hotspots() -> Array[Hotspot]:
	var all_hotspots = get_all_hotspots()
	var found_hotspots: Array[Hotspot] = []
	for hotspot in all_hotspots:
		if hotspot.is_visible_in_tree():
			var object_parts = object.split(" ", false)
			for part in object_parts:
				if part in hotspot.hotspot_id:
					found_hotspots.append(hotspot)
					break
	return found_hotspots;

func get_current_scene():
	return get_tree().current_scene.get_name()
	
func get_closest_key(arr, s):
	for i in arr:
		if s in i:
			return i
	return null

func remove_stopwords(input):
	var words = input.split(" ", false);
#	Allocate new dictionary to store found words
	var found = {};
#	Store results in this StringBuilder
	var str_builder = ""
#	Loop through all words
	for s in words:
		var lower = s.to_lower()
#		Convert to lowercase
#		If this is a usable word, add it
		if lower not in dict.keys():
			str_builder = str(str_builder, lower, " ")
			found[lower] = true
#	Return string with words removed
	return str_builder.strip_edges(true, true)

func remove_special_characters(input):
	# Create a regular expression to match special characters
	var regex = RegEx.new()
	# Match any character that is not a letter, number, or space
	regex.compile("[^a-zA-Z0-9\\s]")
	# Replace all special characters with an empty string
	return regex.sub(input, "", true)


func get_all_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	_find_rooms(get_tree().root, rooms)
	return rooms

func get_all_hotspots() -> Array[Hotspot]:
	var hotspots: Array[Hotspot] = []
	_find_hotspots(get_tree().root, hotspots)
	return hotspots

func _find_rooms(node: Node, result: Array) -> void:
	if node is Room:
		result.append(node)
	
	for child in node.get_children():
		_find_rooms(child, result)

func _find_hotspots(node: Node, result: Array) -> void:
	if node is Hotspot:
		result.append(node)
	
	for child in node.get_children():
		_find_hotspots(child, result)

var dict = {
	"a": true,
	"about": true,
	"above": true,
	"across": true,
	"after": true,
	"afterwards": true,
	"again": true,
	"against": true,
	"all": true,
	"almost": true,
	"alone": true,
	"along": true,
	"already": true,
	"also": true,
	"although": true,
	"always": true,
	"am": true,
	"among": true,
	"amongst": true,
	"amount": true,
	"an": true,
	"and": true,
	"another": true,
	"any": true,
	"anyhow": true,
	"anyone": true,
	"anything": true,
	"anyway": true,
	"anywhere": true,
	"are": true,
	"around": true,
	"as": true,
	"at": true,
	"back": true,
	"be": true,
	"became": true,
	"because": true,
	"become": true,
	"becomes": true,
	"becoming": true,
	"been": true,
	"before": true,
	"beforehand": true,
	"behind": true,
	"being": true,
	"below": true,
	"beside": true,
	"besides": true,
	"between": true,
	"beyond": true,
	"bill": true,
	"both": true,
	"bottom": true,
	"but": true,
	"by": true,
	"call": true,
	"can": true,
	"cannot": true,
	"cant": true,
	"co": true,
	"computer": true,
	"con": true,
	"could": true,
	"couldnt": true,
	"cry": true,
	"de": true,
	"describe": true,
	"detail": true,
	"do": true,
	"done": true,
	"down": true,
	"due": true,
	"during": true,
	"each": true,
	"eg": true,
	"eight": true,
	"either": true,
	"eleven": true,
	"else": true,
	"elsewhere": true,
	"empty": true,
	"enough": true,
	"etc": true,
	"even": true,
	"ever": true,
	"every": true,
	"everyone": true,
	"everything": true,
	"everywhere": true,
	"except": true,
	"few": true,
	"fifteen": true,
	"fify": true,
	"fill": true,
	"find": true,
	"fire": true,
	"first": true,
	"five": true,
	"for": true,
	"former": true,
	"formerly": true,
	"forty": true,
	"found": true,
	"four": true,
	"from": true,
	"front": true,
	"full": true,
	"further": true,
	"get": true,
	"give": true,
	"go": true,
	"had": true,
	"has": true,
	"have": true,
	"he": true,
	"hence": true,
	"her": true,
	"here": true,
	"hereafter": true,
	"hereby": true,
	"herein": true,
	"hereupon": true,
	"hers": true,
	"herself": true,
	"him": true,
	"himself": true,
	"his": true,
	"how": true,
	"however": true,
	"hundred": true,
	"i": true,
	"ie": true,
	"if": true,
	"in": true,
	"inc": true,
	"indeed": true,
	"interest": true,
	"into": true,
	"is": true,
	"it": true,
	"its": true,
	"itself": true,
	"keep": true,
	"last": true,
	"latter": true,
	"latterly": true,
	"least": true,
	"less": true,
	"ltd": true,
	"made": true,
	"many": true,
	"may": true,
	"me": true,
	"meanwhile": true,
	"might": true,
	"mill": true,
	"mine": true,
	"more": true,
	"moreover": true,
	"most": true,
	"mostly": true,
	"move": true,
	"much": true,
	"must": true,
	"my": true,
	"myself": true,
	"name": true,
	"namely": true,
	"neither": true,
	"never": true,
	"nevertheless": true,
	"next": true,
	"nine": true,
	"no": true,
	"nobody": true,
	"none": true,
	"nor": true,
	"not": true,
	"nothing": true,
	"now": true,
	"nowhere": true,
	"of": true,
	"off": true,
	"often": true,
	"on": true,
	"once": true,
	"one": true,
	"only": true,
	"onto": true,
	"or": true,
	"other": true,
	"others": true,
	"otherwise": true,
	"our": true,
	"ours": true,
	"ourselves": true,
	"out": true,
	"over": true,
	"own": true,
	"part": true,
	"per": true,
	"perhaps": true,
	"please": true,
	"put": true,
	"rather": true,
	"re": true,
	"same": true,
	"see": true,
	"seem": true,
	"seemed": true,
	"seeming": true,
	"seems": true,
	"serious": true,
	"several": true,
	"she": true,
	"should": true,
	"show": true,
	"side": true,
	"since": true,
	"sincere": true,
	"six": true,
	"sixty": true,
	"so": true,
	"some": true,
	"somehow": true,
	"someone": true,
	"something": true,
	"sometime": true,
	"sometimes": true,
	"somewhere": true,
	"still": true,
	"such": true,
	"system": true,
	"ten": true,
	"than": true,
	"that": true,
	"the": true,
	"their": true,
	"them": true,
	"themselves": true,
	"then": true,
	"thence": true,
	"there": true,
	"thereafter": true,
	"thereby": true,
	"therefore": true,
	"therein": true,
	"thereupon": true,
	"these": true,
	"they": true,
	"thick": true,
	"thin": true,
	"third": true,
	"this": true,
	"those": true,
	"though": true,
	"three": true,
	"through": true,
	"throughout": true,
	"thru": true,
	"thus": true,
	"to": true,
	"together": true,
	"too": true,
	"top": true,
	"toward": true,
	"towards": true,
	"twelve": true,
	"twenty": true,
	"two": true,
	"un": true,
	"under": true,
	"until": true,
	"up": true,
	"upon": true,
	"us": true,
	"very": true,
	"via": true,
	"was": true,
	"we": true,
	"well": true,
	"were": true,
	"what": true,
	"whatever": true,
	"when": true,
	"whence": true,
	"whenever": true,
	"where": true,
	"whereafter": true,
	"whereas": true,
	"whereby": true,
	"wherein": true,
	"whereupon": true,
	"wherever": true,
	"whether": true,
	"which": true,
	"while": true,
	"whither": true,
	"who": true,
	"whoever": true,
	"whole": true,
	"whom": true,
	"whose": true,
	"why": true,
	"will": true,
	"with": true,
	"within": true,
	"without": true,
	"would": true,
	"yet": true,
	"you": true,
	"your": true,
	"yours": true,
	"yourself": true,
	"yourselves": true,
}

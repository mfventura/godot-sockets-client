extends Node
#This class is a node that could be autoloaded or included in the game manager
class_name STOMPClient

"""
WebSocketClient.connected_to_server
WebSocketClient.connection_closed
WebSocketClient.message_received
"""

@export var URL = "ws://localhost:8080/ws"
@export var headers = []

# Called when the node enters the scene tree for the first time.
func _ready():
	WebSocketClient.message_received.connect(_process_message)
	WebSocketClient.connect_to_url(URL)

func reconnect():
	#TODO
	pass

func _process(delta):
	WebSocketClient.poll()

func _process_message(message: Variant):
	pass

func load_file(file) -> String:
	var f = FileAccess.open(file, FileAccess.READ)
	var content = ""
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		content = content + f.get_line()
		if not f.eof_reached():
			content = content + "\n"
	f.close()
	return content

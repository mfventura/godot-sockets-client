extends Node
#This class is a node that could be autoloaded or included in the game manager
class_name STOMPClient

@export var URL = "ws://localhost:8080/ws"
@export var headers = []

signal connected_to_server
signal disconnected_from_server
signal message_received
signal error_received
signal receipt_received

# Called when the node enters the scene tree for the first time.
func _ready():
	WebSocketClient.message_received.connect(_process_message)
	WebSocketClient.connected_to_server.connect(_connected_to_server)
	WebSocketClient.connection_closed.connect(_connection_closed)

func connect_to_server():
	WebSocketClient.connect_to_url(URL)

func disconnect_server():
	WebSocketClient.get_socket().close()

func _process(delta):
	WebSocketClient.poll()

func _process_message(message: Variant):
	if typeof(message) == TYPE_STRING:
		var lines = message.split("\n")
		var frame = Frame.new()
		frame.name = lines[0]
		var isHeader = true
		for line in lines:
			if line.is_empty():
				isHeader = false
				continue
			if isHeader:
				if line != lines[0]:
					frame.headers.append(line)
			else:
				frame.body = frame.body + "\n" + line
		if frame.name == "CONNECTED":
			connected_to_server.emit()
		elif frame.name == "MESSAGE":
			message_received.emit(frame)
		elif frame.name == "ERROR":
			error_received.emit(frame)
		elif frame.name == "RECEIPT":
			receipt_received.emit(frame)
	else:
		print("Received message is not string")
		print(message)

func _connected_to_server():
	heart_beat()

func _connection_closed():
	disconnected_from_server.emit()

func heart_beat() -> int:
	var content = load_file("res://message_templates/connect.txt")
	return WebSocketClient.send(content)

func subscribe(destination):
	var content = load_file("res://message_templates/subscribe.txt")
	content = content%["user","id",destination,"receipt"]
	WebSocketClient.send(content)

func send_message(message):
	var content = load_file("res://message_templates/send.txt")
	content = content%["godot", message]
	return WebSocketClient.send(content)

func close_connection():
	var content = load_file("res://message_templates/disconnect.txt")
	content = content%"godot"
	return WebSocketClient.send(content)

func load_file(file) -> String:
	var f = FileAccess.open(file, FileAccess.READ)
	var content = ""
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		content = content + f.get_line()
		if not f.eof_reached():
			content = content + "\n"
	f.close()
	return content

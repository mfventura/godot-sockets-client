extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Socket.message_received.connect(message_received)
	Socket.connection_closed.connect(connection_closed)
	Socket.connected_to_server.connect(connection_open)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func message_received(message):
	$log.text = $log.text + "\n" + message

func connection_closed():
	print("Connection closed")
	$connect.visible = true
	$close.visible = false

func _on_button_pressed():
	var err = Socket.send($message.text)
	$message.text = ""

func _on_connect_pressed():
	var err= Socket.connect_to_url("ws://localhost:8080/ws")
	print("Socket connect to url value "+str(err))

func connection_open():
	print("Connection open signal")
	$connect.visible = false
	$close.visible = true


func _on_open_server_pressed():
	var server_scene = load("res://server.tscn")
	add_child(server_scene.instantiate())



func _on_subscribe_pressed():
	Socket.subscribe()


func _on_close_pressed():
	Socket.close()

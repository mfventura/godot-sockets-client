extends Control

func _ready():
	WebSocketClient.message_received.connect(message_received)
	WebSocketClient.connection_closed.connect(connection_closed)
	WebSocketClient.connected_to_server.connect(connection_open)

func _process(delta):
	WebSocketClient.poll()
	
func message_received(message):
	$log.text = $log.text + "\n" + message

func connection_closed():
	print("Connection closed")
	$connect.visible = true
	$close.visible = false

func _on_button_pressed():
	var err = WebSocketClient.send($message.text)
	$message.text = ""

func _on_connect_pressed():
	var err= WebSocketClient.connect_to_url("ws://localhost:8080/ws")

func connection_open():
	print("Connection open")
	$connect.visible = false
	$close.visible = true

func _on_open_server_pressed():
	var server_scene = load("res://server.tscn")
	add_child(server_scene.instantiate())

func _on_subscribe_pressed():
	WebSocketClient.subscribe()

func _on_close_pressed():
	WebSocketClient.close()

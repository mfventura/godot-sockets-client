extends Control

var stomp : STOMPClient = STOMPClient.new()

func _ready():
	add_child(stomp)
	stomp.message_received.connect(message_received)
	stomp.connected_to_server.connect(connection_open)
	stomp.disconnected_from_server.connect(connection_closed)
	stomp.receipt_received.connect(receipt_received)
	
func message_received(frame: Frame):
	$log.text = $log.text + "\n" + frame.body

func connection_closed():
	print("Connection closed")
	$connect.visible = true
	$close.visible = false

func receipt_received(frame: Frame):
	for header in frame.headers:
		if header.begins_with("receipt-id:disconnect"):
			stomp.disconnect_server()

func _on_button_pressed():
	var err = stomp.send_message($message.text)
	$message.text = ""

func _on_connect_pressed():
	var err= stomp.connect_to_server()

func connection_open():
	print("Connection open")
	$connect.visible = false
	$close.visible = true

func _on_open_server_pressed():
	var server_scene = load("res://server.tscn")
	add_child(server_scene.instantiate())

func _on_subscribe_pressed():
	stomp.subscribe("/topic/messages")

func _on_close_pressed():
	stomp.close_connection()

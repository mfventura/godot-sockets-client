extends Node

var tls_options: TLSOptions = null
var socket = WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED


signal connected_to_server()
signal lasignal()
signal message_received(message: Variant)

func _ready():
	pass

func connect_to_url(url) -> int:
	var err = socket.connect_to_url(url, tls_options)
	if err != OK:
		log_message("Error connecting")
		return err
	last_state = socket.get_ready_state()
	return OK

func heart_beat() -> int:
	var content = load_file("res://connect.txt")
	var content_byte_arr = content.to_utf8_buffer()
	content_byte_arr.append_array(PackedByteArray([null]))
	var err = socket.send(content_byte_arr)
	return err

func subscribe() -> int:
	var content = load_file("res://subscribe.txt")
	var content_byte_arr = content.to_utf8_buffer()
	content_byte_arr.append_array(PackedByteArray([null]))
	var err = socket.send(content_byte_arr)
	return err

func send(message) -> int:
	var content = load_file("res://send.txt")
	content = content%["godot", message]
	var content_byte_arr = content.to_utf8_buffer()
	content_byte_arr.append_array(PackedByteArray([null]))
	var err = socket.send(content_byte_arr)
	return err

func get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var pkt = socket.get_packet()
	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)

func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()


func get_socket() -> WebSocketPeer:
	return socket


func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()
	var state = socket.get_ready_state()
	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			lasignal.emit()

	while state == socket.STATE_OPEN and socket.get_available_packet_count() > 0:
		log_message("Message received")
		message_received.emit(get_message())


func _process(delta):
	poll()

func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	var content = ""
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		content = content + f.get_line()
		if not f.eof_reached():
			content = content + "\n"
	f.close()
	return content


func close():
	socket.close()

func log_message(message):
	var time = Time.get_time_string_from_system()
	print("CLIENT: "+time +" "+ message)

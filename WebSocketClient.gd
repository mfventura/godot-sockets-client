class_name WebSocketClient

static var tls_options: TLSOptions = null
static var socket = WebSocketPeer.new()
static var last_state = WebSocketPeer.STATE_CLOSED

static var connected_to_server: Signal = (func():
	(WebSocketClient as Object).add_user_signal("connected_to_server")
	return Signal(WebSocketClient, "connected_to_server")
).call()
static var connection_closed: Signal = (func():
	(WebSocketClient as Object).add_user_signal("connection_closed")
	return Signal(WebSocketClient, "connection_closed")
).call()
static var message_received: Signal = (func():
	(WebSocketClient as Object).add_user_signal("message_received", [{"name": "message", "type": TYPE_OBJECT}])
	return Signal(WebSocketClient, "message_received")
).call()

static func connect_to_url(url) -> int:
	var err = socket.connect_to_url(url, tls_options)
	if err != OK:
		log_message("Error connecting")
		return err
	last_state = socket.get_ready_state()
	return OK

static func heart_beat() -> int:
	var content = load_file("res://message_templates/connect.txt")
	var content_byte_arr = content.to_utf8_buffer()
	content_byte_arr.append_array(PackedByteArray([null]))
	var err = socket.send(content_byte_arr)
	return err

static func subscribe() -> int:
	var content = load_file("res://message_templates/subscribe.txt")
	var content_byte_arr = content.to_utf8_buffer()
	content_byte_arr.append_array(PackedByteArray([null]))
	var err = socket.send(content_byte_arr)
	return err

static func send(message) -> int:
	var content = load_file("res://message_templates/send.txt")
	content = content%["godot", message]
	var content_byte_arr = content.to_utf8_buffer()
	content_byte_arr.append_array(PackedByteArray([null]))
	var err = socket.send(content_byte_arr)
	return err

#This message should be handled by the STOMP message processor
static func get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var pkt = socket.get_packet()
	#Testeo
	var string = pkt.get_string_from_utf8()

	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)

static func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()


static func get_socket() -> WebSocketPeer:
	return socket


static func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()
	var state = socket.get_ready_state()
	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			connection_closed.emit()

	while state == socket.STATE_OPEN and socket.get_available_packet_count() > 0:
		message_received.emit(get_message())

static func close():
	socket.close()

static func log_message(message):
	var time = Time.get_time_string_from_system()
	print("WebSocketClient: "+time +" "+ message)

static func load_file(file) -> String:
	var f = FileAccess.open(file, FileAccess.READ)
	var content = ""
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		content = content + f.get_line()
		if not f.eof_reached():
			content = content + "\n"
	f.close()
	return content

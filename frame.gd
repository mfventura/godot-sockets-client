class_name Frame

var name: String
var headers = []
var body: String

func _to_string():
	var toString = name
	for header in headers:
		toString = toString + "\n" + header
	toString = toString + "\n\n" + body
	return toString

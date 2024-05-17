extends Panel

onready var selectedRow = []

func _ready():
	$HTTPRequest.getTables()


func _on_HTTPRequest_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var res = json.result[0]
	
	$TabContainer.create_tabs(res)


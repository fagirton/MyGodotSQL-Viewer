extends Panel

onready var selectedRow = []

func _ready():
	var spinner = load("res://assets/Loading.tscn")
	$VBoxContainer/TabContainer.add_child(spinner.instance())
	
	_on_CheckButton_toggled($VBoxContainer/HBoxContainer/CheckButton.pressed)

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	if $HTTPRequest.checkError(response_code, body) != null:
		$VBoxContainer/TabContainer.get_node("Empty").get_child(0).text = $HTTPRequest.checkError(response_code, body)
	else:
		for i in $VBoxContainer/TabContainer.get_children():
			i.queue_free()
		
		var json = JSON.parse(body.get_string_from_utf8())
		var res = json.result[0]
		
		$VBoxContainer/TabContainer.create_tabs(res)
		$VBoxContainer/HBoxContainer/CheckButton.disabled = false


func _on_CheckButton_toggled(button_pressed):
	$VBoxContainer/HBoxContainer/CheckButton.disabled = true
	
	if button_pressed:
		$HTTPRequest.getViews()
	else:
		$HTTPRequest.getTables()

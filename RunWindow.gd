extends WindowDialog


onready var menu = $MarginContainer/VBoxContainer/HBoxContainer/MenuButton
onready var params = $MarginContainer/VBoxContainer/HBoxContainer/ParamContainer
onready var procedure = ""

func _on_WindowDialog_about_to_show():
	$HTTPRequest.getProcedures()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if $HTTPRequest.checkError(response_code, body) != null:
		$"MarginContainer/VBoxContainer/Status Container".get_child(0).text += $HTTPRequest.checkError(response_code, body)
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	var res = json.result[0]
	
	if res[0].has("Type") and res[0]["Type"] == "PROCEDURE":
		for i in res:
			menu.get_popup().add_item(i["Name"])
		
		menu.get_popup().connect("id_pressed", self,"_on_item_pressed")
	
	if res[0].has("PARAMETER_NAME"):
		for i in params.get_children():
			i.queue_free()
		
		var editCont = load("res://EditContainer.tscn")
		# Let's assume keys and values have same length
		for i in res:
			var node = editCont.instance()
			node.get_node("Label").text = i["PARAMETER_NAME"] + " (" + i["DATA_TYPE"]+ ")"
			params.add_child(node)

func _on_Run_Button_pressed():
	if procedure != "":
		$HTTPRequest.runProcedure(procedure)

func _on_item_pressed(id):
	procedure = menu.get_popup().get_item_text(id)
	menu.text = procedure
	$HTTPRequest.getProcedureParams(procedure)

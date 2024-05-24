extends WindowDialog


onready var menu = $MarginContainer/VBoxContainer/HBoxContainer/MenuButton
onready var params = $MarginContainer/VBoxContainer/HBoxContainer/ParamContainer
onready var procedure = ""
onready var datatypes = []
onready var paramsOut = []

func _ready():
	$HTTPRequest.getProcedures()

func _on_WindowDialog_about_to_show():
	pass


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if $HTTPRequest.checkError(response_code, body) != null:
		$"MarginContainer/VBoxContainer/Status Container".get_child(0).text += $HTTPRequest.checkError(response_code, body) + "\n"
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	var res = json.result[0]
	
	if res.has("fieldCount"):
		var s = "\n Procedure " + procedure + " Return values:\n"
		for i in json.result[1][0].keys():
			s += i + ": " + str(json.result[1][0][i]) + "\n"
		$"MarginContainer/VBoxContainer/Status Container".get_child(0).text += s
		return
	
	if res[0].has("Type") and res[0]["Type"] == "PROCEDURE":
		for i in res:
			menu.get_popup().add_item(i["Name"])
		menu.get_popup().connect("id_pressed", self,"_on_item_pressed")
	
	if res[0].has("PARAMETER_NAME"):
		for i in params.get_children():
			i.queue_free()
		paramsOut = []
		
		var editCont = load("res://EditContainer.tscn")
		# Let's assume keys and values have same length
		for i in res:
			if i["PARAMETER_MODE"] == "INOUT" or i["PARAMETER_MODE"] == "OUT":
				paramsOut.append(i["PARAMETER_NAME"])
			if i["PARAMETER_MODE"] == "INOUT" or i["PARAMETER_MODE"] == "IN":
				var node = editCont.instance()
				node.get_node("Label").text = i["PARAMETER_NAME"] + " (" + i["DATA_TYPE"]+ ")"
				datatypes.append(i["DATA_TYPE"])
				params.add_child(node)

func _on_Run_Button_pressed():
	var paramNodes = self.find_node("ParamContainer").get_children()
	var params = []
	for i in paramNodes.size():
		params.append(paramNodes[i].get_node("LineEdit").text)
			#lintValue(datatypes[i], paramNodes[i].get_node("LineEdit").text))
	if procedure != "":
		$HTTPRequest.runProcedure(procedure, params, paramsOut)

func _on_item_pressed(id):
	procedure = menu.get_popup().get_item_text(id)
	menu.text = procedure
	$HTTPRequest.getProcedureParams(procedure)

func lintValue(datatype: String, param):
	var type
	var lintedParam
	match datatype:
		"Int":
			type = TYPE_INT
			lintedParam = str2var(param)
		"Datetime":
			type = null
			return null # Dates not implemented yet
		"VARCHAR":
			type = TYPE_STRING
			lintedParam = param
	if typeof(param) == type:
		return lintedParam

func _on_Close_Window_pressed():
	self.hide()

extends Tabs

onready var table = $MarginContainer/HBoxContainer/Table
onready var createB = $MarginContainer/HBoxContainer/VBoxContainer/CreateButton
onready var editB = $MarginContainer/HBoxContainer/VBoxContainer/EditButton
onready var selectB = $MarginContainer/HBoxContainer/VBoxContainer/SelectButton
onready var runB = $MarginContainer/HBoxContainer/VBoxContainer/RunButton

onready var selectedLine = []
onready var keys = []
onready var tableSpecs = {}
onready var windowOpen = false

func _ready():
	# No async loading animations for me I guess
	var spinner = load("res://assets/Loading.tscn")
	$MarginContainer/HBoxContainer.add_child_below_node(table, spinner.instance())
	table.visible = false
	
	$HTTPRequest.selectTable(self.name)

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):	
	if windowOpen:
		if $HTTPRequest.checkError(response_code, body) != null:
			createB.get_child(0).find_node("Status Container").get_child(0).text += $HTTPRequest.checkError(response_code, body)
			editB.get_child(0).find_node("Status Container").get_child(0).text += $HTTPRequest.checkError(response_code, body)
			runB.get_child(0).find_node("Status Container").get_child(0).text += $HTTPRequest.checkError(response_code, body)
		return true
	
	if $HTTPRequest.checkError(response_code, body) != null and !windowOpen:
		$MarginContainer/HBoxContainer.get_node("Empty").get_child(0).text = $HTTPRequest.checkError(response_code, body)
		return true
	
	if $MarginContainer/HBoxContainer.get_node("Empty") != null:
		$MarginContainer/HBoxContainer.get_node("Empty").queue_free()
	table.visible = true
	
	var json = JSON.parse(body.get_string_from_utf8())
	var res = json.result[0]
	
	if res[0].has("Field"):
		for i in res:
			tableSpecs[i["Field"]] = i["Type"]
		return
	
	if typeof(json.result) == TYPE_ARRAY:
		keys = res[0].keys()
		table._set_column_headers(keys)
		var values_arr: Array = []
		for i in res:
			values_arr.append(i.values())
		table.set_rows(values_arr)
		$HTTPRequest.tableSpecs(self.name)


func _on_CreateButton_pressed():
	windowOpen = true
	createB.get_child(0).popup_centered()
	createB.get_child(0).render(tableSpecs.keys(), tableSpecs.values(), selectedLine, self.name, true)


func _on_EditButton_pressed():
	windowOpen = true
	editB.get_child(0).popup_centered()
	editB.get_child(0).render(tableSpecs.keys(), tableSpecs.values(), selectedLine, self.name, false)


func _on_SelectButton_pressed():
	$HTTPRequest.selectTable(self.name)


func _on_Table_CLICK_ROW(value):
	selectedLine = value
	createB.set_disabled(false)
	editB.set_disabled(false)


func _on_WindowDialog_postChanges(keys, oldValues, newValues):
	print(keys, oldValues, newValues)
	$HTTPRequest.updateValues(self.name, arrToDict(keys, oldValues), arrToDict(keys, newValues))


func _on_WindowDialog_reloadData():
	_on_SelectButton_pressed()


func _on_WindowDialog_createEntry(keys, newValues):
	print(keys, newValues)
	$HTTPRequest.insertValues(self.name, arrToDict(keys, newValues))

func arrToDict(keys: Array, values: Array):
	var dict: Dictionary
	for i in keys.size():
		dict[keys[i]] = values[i]
	return dict


func _on_RunButton_pressed():
	windowOpen = true
	runB.get_child(0).popup_centered()


func _on_WindowDialog_popup_hide():
	windowOpen = false

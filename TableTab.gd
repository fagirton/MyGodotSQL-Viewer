extends Tabs

onready var table = $MarginContainer/HBoxContainer/Table
onready var createB = $MarginContainer/HBoxContainer/VBoxContainer/CreateButton
onready var editB = $MarginContainer/HBoxContainer/VBoxContainer/EditButton
onready var selectB = $MarginContainer/HBoxContainer/VBoxContainer/SelectButton

onready var selectedLine = []
onready var keys = []

func _ready():
	$HTTPRequest.selectTable(self.name)

func _on_HTTPRequest_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var res = json.result[0]
	if typeof(json.result) == TYPE_ARRAY:
		keys = res[0].keys()
		table._set_column_headers(keys)
		var values_arr: Array = []
		for i in res:
			values_arr.append(i.values())
		table.set_rows(values_arr)



func _on_CreateButton_pressed():
	createB.get_child(0).popup_centered()
	createB.get_child(0).render(keys, selectedLine, self.name, true)



func _on_EditButton_pressed():
	editB.get_child(0).popup_centered()
	editB.get_child(0).render(keys, selectedLine, self.name, false)


func _on_SelectButton_pressed():
	$HTTPRequest.selectTable(self.name)


func _on_Table_CLICK_ROW(value):
	selectedLine = value
	createB.set_disabled(false)
	editB.set_disabled(false)


func _on_WindowDialog_postChanges():
	pass


func _on_WindowDialog_reloadData():
	_on_SelectButton_pressed()


func _on_WindowDialog_createEntry():
	pass # Replace with function body.

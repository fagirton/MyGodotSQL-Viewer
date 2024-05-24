extends WindowDialog


onready var fieldsCont = $MarginContainer/VBoxContainer/HBoxContainer/FieldsContainer

onready var gkeys = []
onready var oldValues = []
onready var newValues = []

signal createEntry(keys, newV)
signal postChanges(keys, oldV, newV)
signal reloadData

func render(keys: Array, types: Array, values: Array, tableName: String, isCreateMode: bool):
	print(keys)
	print(values)
	
	gkeys = keys
	oldValues = values
	var editCont = load("res://EditContainer.tscn")
	# Let's assume keys and values have same length
	for i in keys.size():
		var node = editCont.instance()
		node.get_node("Label").text = keys[i] + " (" + types[i] +")"
		if !isCreateMode and str(values[i]) != "Null":
			node.get_node("LineEdit").text = str(values[i])
		fieldsCont.add_child(node)
	if isCreateMode:
		$MarginContainer/VBoxContainer/Label.text = "Creating new entry in " + tableName
		self.window_title = "Add new entry"
		self.find_node("Save Button").text = "Create"
	else:
		$MarginContainer/VBoxContainer/Label.text = "Editing entry in " + tableName
		self.window_title = "Edit existing entry"
		self.find_node("Save Button").text = "Update"

func _on_WindowDialog_popup_hide():
	$"MarginContainer/VBoxContainer/Status Container/Label".text = "Operation status:"
	gkeys = []
	oldValues = []
	newValues = []
	for i in fieldsCont.get_children():
		i.queue_free()

func _on_Save_Button_pressed():
	newValues = []
	for i in fieldsCont.get_children():
		newValues.append(str2var(i.get_node("LineEdit").text))
	if oldValues.hash() != newValues.hash():
		if $MarginContainer/VBoxContainer/Label.text[0] == "C":
			emit_signal("createEntry", gkeys, newValues)
		else:
			emit_signal("postChanges", gkeys, newValues, oldValues)
	
	emit_signal("reloadData")
func _on_Close_Window_pressed():
	self.hide()

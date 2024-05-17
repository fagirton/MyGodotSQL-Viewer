extends WindowDialog


onready var fieldsCont = $MarginContainer/VBoxContainer/HBoxContainer/FieldsContainer

signal createEntry
signal postChanges
signal reloadData

func render(keys: Array, values: Array, tableName: String, isCreateMode: bool):
	print(keys)
	print(values)
	var editCont = load("res://EditContainer.tscn")
	# Let's assume keys and values have same length
	for i in values.size():
		var node = editCont.instance()
		node.get_node("Label").text = keys[i]
		if str(values[i]) != "Null" and !isCreateMode:
			node.get_node("LineEdit").text = str(values[i])
		fieldsCont.add_child(node)
	if isCreateMode:
		$MarginContainer/VBoxContainer/Label.text = "Creating new entry in " + tableName
	else:
		$MarginContainer/VBoxContainer/Label.text = "Editing entry in " + tableName

func _on_WindowDialog_popup_hide():
	for i in fieldsCont.get_children():
		i.queue_free()


func _on_Save_Button_pressed():
	if $MarginContainer/VBoxContainer/Label.text[0] == "C":
		emit_signal("createEntry")
	else:
		emit_signal("postChanges")
	
	emit_signal("reloadData")
	self.hide()

func _on_Close_Window_pressed():
	self.hide()

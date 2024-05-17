extends TabContainer

func _ready():
	pass # Replace with function body.

func create_tabs(array):
	var tableTab = load("res://TableWindow.tscn")
	for i in array:
		var node = tableTab.instance()
		node.name = i.values()[0]
		add_child(node)

extends WindowDialog


signal ok

func _on_OK_pressed():
	emit_signal("ok")


func _on_Cancel_pressed():
	self.hide()

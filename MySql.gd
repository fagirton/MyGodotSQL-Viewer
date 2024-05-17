extends HTTPRequest

var url = "http://localhost:3000"

func _ready():
	pass # Replace with function body.


func getTables():
	self.queryRun("show full tables where Table_Type = 'BASE TABLE'")
	
func selectTable(tableName):
	self.queryRun("SELECT * FROM " + tableName)

func insertValues(tableName: String, object: Dictionary):
	#self.queryRun()
	print("INSERT INTO " + tableName + "(" + var2str(object.keys()).trim_prefix("[ ").trim_suffix(" ]") + ") VALUES(" + var2str(object.values()).trim_prefix("[ ").trim_suffix(" ]") + ")")


func updateValues(tableName: String, object: Dictionary, primaryKey: String):
	pass

func queryRun(text: String):
	var text1 = {"query": text }
	var json = JSON.print(text1)
	var headers = ["Content-Type: application/json"]
	return request(url, headers, true, HTTPClient.METHOD_POST, json)

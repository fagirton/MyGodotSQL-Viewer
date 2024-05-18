extends HTTPRequest

var url = "http://localhost:3000"

func _ready():
	pass # Replace with function body.

func checkError(response_code, body):
	if response_code == 400:
		var json = JSON.parse(body.get_string_from_utf8())
		return json.result["error"]
	else:
		return null

func getProcedures():
	self.queryRun("SHOW PROCEDURE STATUS WHERE db = DATABASE()")

func getProcedureParams(name):
	self.queryRun('SELECT PARAMETER_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.PARAMETERS WHERE SPECIFIC_NAME="' + name + '"')

func runProcedure(name):
	print(name)
	pass

func getTables():
	self.queryRun("show full tables where Table_Type = 'BASE TABLE'")

func getViews():
	self.queryRun("show full tables where Table_Type = 'VIEW'")
	
func selectTable(tableName):
	self.queryRun("SELECT * FROM " + tableName)

func insertValues(tableName: String, object: Dictionary):
	#self.queryRun()
	print("INSERT INTO " + tableName + "(" + var2str(object.keys()).trim_prefix("[ ").trim_suffix(" ]") + ") VALUES(" + var2str(object.values()).trim_prefix("[ ").trim_suffix(" ]") + ")")


func updateValues(tableName: String, object: Dictionary, oldObject: Dictionary):
	var set = ""
	var where = ""
	for i in object.keys():
		print(typeof(object[i]))
		if typeof(oldObject[i]) == TYPE_INT or typeof(oldObject[i]) == TYPE_REAL or object[i] == "Null": 
			set = set + i + ' = ' + str(object[i]) + ', '
		else:
			set = set + i + ' = "' + str(object[i]) + '", '
		
	set.erase(set.length() - 2, 2)
	for i in oldObject.keys():
		print(typeof(oldObject[i]))
		if typeof(oldObject[i]) == TYPE_INT or typeof(oldObject[i]) == TYPE_REAL or typeof(oldObject[i]) == TYPE_NIL: 
			where = where + i + ' = ' + str(oldObject[i]) + ', '
		else:
			where = where + i + ' = "' + str(oldObject[i]) + '", '
	where.erase(where.length() - 2, 2)
	print("UPDATE " + tableName + " SET " + set + " WHERE " + where)


func queryRun(text: String):
	var text1 = {"query": text }
	var json = JSON.print(text1)
	var headers = ["Content-Type: application/json"]
	return request(url, headers, true, HTTPClient.METHOD_POST, json)

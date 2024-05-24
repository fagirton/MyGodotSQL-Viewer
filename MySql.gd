extends HTTPRequest

var url = "http://localhost:3000" # Используемый URL Nest сервера

func checkError(response_code, body): # Функция возвращающая ошибки HTTP-запроса при их наличии
	if response_code == 400:
		var json = JSON.parse(body.get_string_from_utf8())
		return json.result["error"]
	else:
		return null

func getProcedures(): # Функция, получающая процедуры из базы данных
	self.queryRun(["SHOW PROCEDURE STATUS WHERE db = DATABASE()"])

func getProcedureParams(name): # Функция, получающая параметры процедуры из базы данных по её названию
	self.queryRun(['SELECT PARAMETER_NAME, DATA_TYPE, PARAMETER_MODE FROM INFORMATION_SCHEMA.PARAMETERS WHERE SPECIFIC_NAME="' + name + '"'])

func runProcedure(name: String, paramsIn: Array, paramsOut: Array): # Функция для запуска процедуры
	var paramsInString = ""
	var paramsOutString = ""
	for i in paramsIn:
		paramsInString += i + ", "
	for i in paramsOut:
		paramsOutString += "@" + i+ ", "
	paramsOutString = paramsOutString.trim_suffix(", ")
	print(["CALL " + name + "(" + paramsInString + paramsOutString + ");", "SELECT " + paramsOutString + ";"])
	self.queryRun(["CALL " + name + "(" + paramsInString + paramsOutString + ");", "SELECT " + paramsOutString + ";"])

func getTables(): # Функция для получения таблиц
	self.queryRun(["show full tables where Table_Type = 'BASE TABLE'"])

func getViews(): # Функция для получения представлений 
	self.queryRun(["show full tables where Table_Type = 'VIEW'"])
	
func selectTable(tableName): # Функция для получения содержимого таблицы
	self.queryRun(["SELECT * FROM " + tableName])

func tableSpecs(tableName): # Функция для получения состава таблицы: поля и типы данных
	self.queryRun(["DESCRIBE " + tableName])

func insertValues(tableName: String, object: Dictionary): # Функция для вставки значений в таблицу
	print(arrToCount(object.keys(), "`"))
	print(arrToCount(object.values(), "'"))
	self.queryRun(["INSERT INTO " + tableName + "(" + arrToCount(object.keys(), "`") + ") VALUES(" + arrToCount(object.values(), "'") + ")"])

func deleteEntry(tableName: String, oldObject: Dictionary):
	var where = ""
	for i in oldObject.keys():
		print(typeof(oldObject[i]))
		if typeof(oldObject[i]) == TYPE_INT or typeof(oldObject[i]) == TYPE_REAL or typeof(oldObject[i]) == TYPE_NIL: 
			where = where + i + ' = ' + str(oldObject[i]) + ' and '
		else:
			where = where + i + " = '" + str(oldObject[i]) + "' and "
	where.erase(where.length() - 5, 5)
	self.queryRun(["DELETE FROM " + tableName + " WHERE " + where])

func updateValues(tableName: String, object: Dictionary, oldObject: Dictionary): # Функция обновления значений в таблице
	var set = ""
	var where = ""
	for i in object.keys():
		print(typeof(object[i]))
		if typeof(oldObject[i]) == TYPE_INT or typeof(oldObject[i]) == TYPE_REAL or object[i] == "Null": 
			set = set + i + ' = ' + str(object[i]) + ', '
		else:
			set = set + i + " = '" + str(object[i]) + "', "
		
	set.erase(set.length() - 2, 2)
	for i in oldObject.keys():
		print(typeof(oldObject[i]))
		if typeof(oldObject[i]) == TYPE_INT or typeof(oldObject[i]) == TYPE_REAL or typeof(oldObject[i]) == TYPE_NIL: 
			where = where + i + ' = ' + str(oldObject[i]) + ' and '
		else:
			where = where + i + " = '" + str(oldObject[i]) + "' and "
	where.erase(where.length() - 5, 5)
	self.queryRun(["UPDATE " + tableName + " SET " + set + " WHERE " + where])


func queryRun(texts: Array): # Функция для запуска SQL выражений
	print(texts)
	var text1 = {"queries": texts }
	var json = JSON.print(text1)
	print(json)
	var headers = ["Content-Type: application/json"]
	return request(url, headers, true, HTTPClient.METHOD_POST, json)

func arrToCount(arr: Array, delimiter: String): # Функция, переводящая массив значений в строку с перечислением 
	var s = ""
	for i in arr:
		if typeof(i) == TYPE_STRING:
			s += delimiter + i + delimiter + ", "
		else:
			s += str(i) + ", "
	s.erase(s.length() - 2, 2)
	return s

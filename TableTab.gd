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
	# Добавить в сцену текст "Загрузка"
	var spinner = load("res://assets/Loading.tscn")
	$MarginContainer/HBoxContainer.add_child_below_node(table, spinner.instance())
	table.visible = false
	
	# Запросить содержимое таблицы
	$HTTPRequest.selectTable(self.name)

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body): # Функция вызываемая, когда пришёл HTTP запрос
	# Действия для запросов из окна Создания/Обновления/Запуска процедуры
	if windowOpen:
		# В случае обнаружения ошибки добавить текст в поле Operation status:
		if $HTTPRequest.checkError(response_code, body) != null:
			createB.get_child(0).find_node("Status Container").get_child(0).text = "Operation status:" + $HTTPRequest.checkError(response_code, body) + "\n"
			editB.get_child(0).find_node("Status Container").get_child(0).text = "Operation status:" + $HTTPRequest.checkError(response_code, body) + "\n"
			runB.get_child(0).find_node("Status Container").get_child(0).text += $HTTPRequest.checkError(response_code, body) + "\n"
		return true
	
	# В случае ошибки в основном окне (при получении содержимого таблицы) вставить текст ошибки вместо надписи "Загрузка" посередине
	if $HTTPRequest.checkError(response_code, body) != null and !windowOpen:
		$MarginContainer/HBoxContainer.get_node("Empty").get_child(0).text = $HTTPRequest.checkError(response_code, body)
		return true
	
	# Если ошибок не было, убираем надпись "Загрузка" в центре окна и включаем видимость таблицы
	if $MarginContainer/HBoxContainer.get_node("Empty") != null:
		$MarginContainer/HBoxContainer.get_node("Empty").queue_free()
	table.visible = true
	
	# Обрабатываем данные из запроса
	var json = JSON.parse(body.get_string_from_utf8())
	var res = json.result[0]
	
	# Если в запросе были только объекты с полем "Field", значит это пришли названия и типы данных полей таблицы, запишем их в переменную
	if res[0].has("Field"):
		for i in res:
			tableSpecs[i["Field"]] = i["Type"]
		return
	
	# Если в результате пришёл массив и предыдущее не сработало, это содержимое таблицы, заполним его в объект таблицы в текущем окне 
	if typeof(json.result) == TYPE_ARRAY:
		keys = res[0].keys()
		table._set_column_headers(keys)
		var values_arr: Array = []
		for i in res:
			values_arr.append(i.values())
		table.set_rows(values_arr)
		$HTTPRequest.tableSpecs(self.name)

# При нажатии на Create открываем окно EditCreateWindow с настройкой на Create режим, передаем ему названия и типы данных полей таблицы, текущую выбранную строку
func _on_CreateButton_pressed():
	windowOpen = true
	createB.get_child(0).popup_centered()
	createB.get_child(0).render(tableSpecs.keys(), tableSpecs.values(), selectedLine, self.name, true)

# При нажатии на Edit открываем окно EditCreateWindow с настройкой на Edit режим, передаем ему названия и типы данных полей таблицы, текущую выбранную строку
func _on_EditButton_pressed():
	windowOpen = true
	editB.get_child(0).popup_centered()
	editB.get_child(0).render(tableSpecs.keys(), tableSpecs.values(), selectedLine, self.name, false)

# При нажатии на кнопку Reload обновляем содержимое таблицы
func _on_SelectButton_pressed():
	$HTTPRequest.selectTable(self.name)

# При нажатии на строку таблицы записать её в текущую выбранную таблицу и включить кнопки Create Edit 
func _on_Table_CLICK_ROW(value):
	selectedLine = value
	createB.set_disabled(false)
	editB.set_disabled(false)

# При получении сигнала postChanges от окна EditCreateWindow отправляем запрос на обновление значений
func _on_WindowDialog_postChanges(keys, oldValues, newValues):
	print(keys, oldValues, newValues)
	$HTTPRequest.updateValues(self.name, arrToDict(keys, oldValues), arrToDict(keys, newValues))

# При получении сигнала reloadData от окна EditCreateWindow делаем то же самое что и при нажатии кнопки Reload
func _on_WindowDialog_reloadData():
	_on_SelectButton_pressed()

# При получении сигнала createEntry от окна EditCreateWindow отправляем запрос на создание новой строки в таблице
func _on_WindowDialog_createEntry(keys, newValues):
	print(keys, newValues)
	$HTTPRequest.insertValues(self.name, arrToDict(keys, newValues))

# Функция преобразования двух массивов в словарь
func arrToDict(keys: Array, values: Array):
	var dict: Dictionary
	for i in keys.size():
		dict[keys[i]] = values[i]
	return dict

# При нажатии на кнопку Run открываем окно запуска процедуры
func _on_RunButton_pressed():
	windowOpen = true
	runB.get_child(0).popup_centered()

# Обновляем флаг при закрытии любого окна из кнопок
func _on_WindowDialog_popup_hide():
	windowOpen = false

# При получении сигнала на удаление от окна EditCreateWindow отправляем запрос на удаление строки
func _on_WindowDialog_deleteEntry(keys, oldValues):
	$HTTPRequest.deleteEntry(self.name, arrToDict(keys, oldValues))

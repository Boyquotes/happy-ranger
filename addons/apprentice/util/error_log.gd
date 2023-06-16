#============================================================
#    Condition Log
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-10 16:04:50
# - version: 4.x
#============================================================
## 错误日志打印
class_name ErrorLog


static func is_true(expression: bool, message: String) -> void:
	if expression:
		_print(message)

static func is_false(expression: bool, message: String) -> void:
	if not expression:
		_print(message)

static func is_null(expression, message: String) -> void:
	if expression == null:
		_print(message)

static func not_null(expression, message: String) -> void:
	if expression != null:
		_print(message)

static func is_zero(expression: float, message: String) -> void:
	if expression == 0:
		_print(message)


static func _print(message):
	push_error(message)
	printerr(message)

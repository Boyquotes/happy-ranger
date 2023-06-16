#============================================================
#    Base Role Fnode
#============================================================
# - datetime: 2023-02-21 11:09:35
#============================================================
class_name ConfigRole
extends FNode


var role : Role :
	get: return actor
var listener : RoleListener:
	get: return role.role_listener
var listen_id_list : Array[StringName] = []

var __init_listener__ = FuncUtil.call_once_in_tree(self, func():
	listener.listened.connect(func(id, _signal: Signal, method: Callable, priority: int):
		if method.get_object() == self:
			listen_id_list.append(id)
	)
)


#============================================================
#  SetGet
#============================================================
func get_actor() -> Role:
	return actor

## 获取监听器
func get_listener() -> RoleListener:
	return listener


#============================================================
#  内置
#============================================================
func _exit_tree():
	for id in listen_id_list:
		listener.cancel(id)


#============================================================
#  自定义
#============================================================
func print_error(message):
	var list = []
	if message is String:
		list.append(message)
	elif message is Array:
		list = message
	
	printerr( role, " | ", self, " | ", "".join(list) )
	


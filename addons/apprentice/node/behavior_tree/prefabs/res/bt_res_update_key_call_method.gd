#============================================================
#    Bt Action Update Key Res
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 20:52:44
# - version: 4.0
#============================================================
class_name BTResUpdateKeyCallMethod
extends BTResUpdateKey


@export var target : Node
@export var method : StringName
@export var parameters : Array = []


func _to_string():
	return (get_script() as GDScript).resource_path.get_file().get_basename()


func get_value():
	return target.call(method, parameters)


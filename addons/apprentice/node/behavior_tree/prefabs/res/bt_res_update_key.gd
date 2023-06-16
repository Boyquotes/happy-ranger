#============================================================
#    Bt Update Key Res
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 20:55:55
# - version: 4.0
#============================================================
class_name BTResUpdateKey
extends Resource


@export var key : String


var _owner : BTNode


## 这个资源的所有者
func set_owner(owner: BTNode) -> void:
	_owner = owner


func get_owner() -> BTNode:
	return _owner


func get_value():
	pass



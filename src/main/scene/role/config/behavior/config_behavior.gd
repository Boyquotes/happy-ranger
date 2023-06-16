#============================================================
#    Config Behavior
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-11 13:21:56
# - version: 4.x
#============================================================
## 行为节点
class_name ConfigBehavior
extends ConfigRole


## 是否执行这个行为
@export var enabled : bool = false : set=_set_enabled


## 重写这个行为以进行使用
func _set_enabled(value: bool) -> void:
	enabled = value
	printerr("需要重写 %s 的 _set_enabled 方法" % [self])
	breakpoint


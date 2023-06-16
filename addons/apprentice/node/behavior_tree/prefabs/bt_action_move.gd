#============================================================
#    Fbt Move
#============================================================
# - datetime: 2022-09-14 20:02:17
#============================================================
##  从 [member from] 的位置移动到 [member to] 的位置，发送移动信号，设置移动到的位置
@tool
class_name BTActionMove
extends BTActionLeaf


##  移动到方向，这个信号会每帧不断地调用
signal moved(vector: Vector2)


## 发出 [signal moved] 信号时发出的移动到的位置是“到达的方向”或“到达的位置”
@export_enum("Direction", "Position")
var signal_parameter_type : int = 0:
	set(v):
		signal_parameter_type = v
		notify_property_list_changed()
## 从这个位置开始
var from : String
## 要到达的位置
var to : String


#============================================================
#  内置
#============================================================
func _get_property_list():
	var list = []
	match signal_parameter_type:
		0:
			list.append({ 
				"name": "from", 
				"type": TYPE_STRING, 
				"usage": PROPERTY_USAGE_DEFAULT, 
			})
	list.append({ 
		"name": "to", 
		"type": TYPE_STRING, 
		"usage": PROPERTY_USAGE_DEFAULT, 
	})
	return list


#============================================================
#  自定义
#============================================================
#(override)
func _do():
	var to_pos = root.get_global_value(to) as Vector2
	if signal_parameter_type == 0:
		var from_pos = root.get_global_value(from) as Vector2
		moved.emit( from_pos.direction_to(to_pos) )
	else:
		moved.emit(to)



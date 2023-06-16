#============================================================
#    Bt Number Value
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-07 18:09:29
# - version: 4.0
#============================================================
class_name BTResRandomNumberValue
extends BTResNumberValue


@export var min_value : float = 0.0
@export var max_value : float = 0.0


func get_value() -> float:
	return randf_range(min_value, max_value)

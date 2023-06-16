#============================================================
#    Sprint
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-22 15:42:21
# - version: 4.0
#============================================================
class_name SprintFunction
extends BaseTargetObjectOrPoint


## 方向
@export var direction : Vector2
## 速度
@export_range(0, 1, 0.001, "hide_slider", "or_greater", "or_less", "suffix:(pixel/s)")
var speed : float = 0.0


#(override)
func _execute():
	# 移动
	var dir : Vector2 = direction * speed
	execute_duration_process(
		duration
		, func(): role.move_vector(dir)
		, self.emit_finish
	)


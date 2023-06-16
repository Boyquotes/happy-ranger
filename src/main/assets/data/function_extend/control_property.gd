#============================================================
#    Control Property
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 15:14:18
# - version: 4.0
#============================================================
class_name ControlPropertyFunction
extends BaseTargetObject


@export var property: String = ""
@export var value : float = 0.0
@export var count : int = -1
@export var interval : float = 0.0


#(override)
func _execute():
	var callback = func():
		target_object[property] += value
	
	if count > 0 and interval > 0:
		execute_count_process(
			count, 
			interval, 
			callback, 
			self.emit_finish
		)
		
	else:
		execute_duration_process(
			duration,
			callback,
			self.emit_finish
		)
	

#============================================================
#    Call Method
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 22:31:47
# - version: 4.0
#============================================================
class_name CallMethodFunction
extends BaseTargetObject


@export var method: String = ""
@export var parameters : Array = []
@export var interval : float = 0
@export var count : int = -1


#(override)
func _execute():
	super._execute()
	
	if interval > 0 or count > 0:
		execute_count_process(
			count, 
			interval,
			func(): target_object.callv(method, parameters),
			self.emit_finish
		)
		
	else:
		execute_duration_process(
			duration, 
			func(): target_object.callv(method, parameters),
			self.emit_finish
		)
		

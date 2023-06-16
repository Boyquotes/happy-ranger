#============================================================
#    Bt Action Remote Task
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-08 19:32:20
# - version: 4.0
#============================================================
## 远程调用返回执行结果。执行时会调用目标节点，并返回目标节点执行的返回结果
class_name BTActionRemoteTask
extends BTActionLeaf


@export_enum("Success", "Fail", "Running")
var default_result = 0
@export var target_node : BTNode


var result = SUCCEED


#(override)
func _task():
	if target_node:
		result = target_node._task()
		if result == null:
			return default_result
		return result
	return default_result


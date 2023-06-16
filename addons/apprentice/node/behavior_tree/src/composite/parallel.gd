#============================================================
#    Parallel
#============================================================
# - datetime: 2022-09-14 01:00:04
#============================================================
## Paraller 并行节点
##
##从上到下一直执行，如果有 [enum BTNode.RUNNING] 状态，则一直执行，直到执行完全部的节点，并返回执行结果。
##返回子节点执行的结果，优先返回 FAILED，然后是 RUNNING，最后是 SUCCEED。
@tool
@icon("../../icon/FParallel.png")
class_name BTParallel
extends BTComposite


var result = SUCCEED
var result_map : Dictionary


#(override)
func _task():
	result_map = {
		SUCCEED: 0,
		RUNNING: 0,
		FAILED: 0,
	}
	
	# 运行全部子节点
	for i in get_child_count():
		result = get_child(i)._task()
		result_map[result] += 1
	
	if result_map[FAILED]:
		result = FAILED
	elif result_map[RUNNING]:
		result = RUNNING
	else:
		result = SUCCEED
	
	return result

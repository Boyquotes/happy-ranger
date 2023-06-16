#============================================================
#    Selector
#============================================================
# - datetime: 2022-09-14 00:59:21
#============================================================

## Selector 执行失败则继续执行，执行一次成功则返回成功，下次重新开始执行
@tool
@icon("../../icon/FSelector.png")
class_name BTSelector
extends BTComposite


var result = FAILED


#(override)
func _task():
	while task_idx < get_child_count():
		result = get_child(task_idx)._task()
		# 执行失败继续执行下一个，直到成功败或结束
		if result == FAILED:
			task_idx += 1
		elif result == RUNNING:
			return RUNNING
		else:
			task_idx = 0
			return SUCCEED
	
	task_idx = 0
	# 如果都没有成功执行的，则回 FAILED
	return FAILED
	

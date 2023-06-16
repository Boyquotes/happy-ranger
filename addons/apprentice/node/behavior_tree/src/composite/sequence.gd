#============================================================
#    Sequence
#============================================================
# - datetime: 2022-09-14 00:59:36
#============================================================
## Sequence 执行成功则继续执行，执行一次失败则返回失败
@tool
@icon("../../icon/FSequence.png")
class_name BTSequence
extends BTComposite


var result = SUCCEED


#(override)
func _task():
	while task_idx < get_child_count():
		result = get_child(task_idx)._task()
		# 执行成功继续执行下一个，直到失败或结束
		if result == SUCCEED:
			task_idx += 1
		elif result == RUNNING:
			return RUNNING
		else:
			task_idx = 0
			return FAILED
	
	task_idx = 0
	# 如果都没有执行失败的，则回 SUCCEED
	return SUCCEED
	

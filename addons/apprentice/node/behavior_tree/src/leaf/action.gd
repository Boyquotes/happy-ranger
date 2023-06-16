#============================================================
#    Action
#============================================================
# - datetime: 2022-09-14 01:03:04
#============================================================
##  行为节点。重写功能 [method _do] 方法实现功能
@icon("../../icon/FAction.png")
class_name BTActionLeaf
extends BTLeaf


var _result


#(override)
func _task():
	_do()
	return SUCCEED


##  重写方法以执行每帧的功能
func _do():
	pass




#============================================================
#    Bt Action Enter
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 16:58:19
# - version: 4.0
#============================================================
## 进入或退出这个任务时，自动调用 [method _enter] 方法。如果下一帧时没有执行这个任务时，
##会自动调用 [method _exit] 方法
class_name BTActionEnterExit
extends BTActionLeaf


## 再一次进入这个节点时发出
signal entered
## 退出将在下一帧没有经过调用这个节点时发出
signal exited


var _status : int = 2

var __init__ = (func():(func():
	Engine.get_main_loop().physics_frame.connect(func():
		_status += 1
		if _status == 2:
			exited.emit()
			_exit()
	)
).call_deferred()).call()


#(override)
func _task():
	if _status > 1:
		entered.emit()
		_enter()
	_status = 0
	super._task()
	return SUCCEED


## 进入这个节点时自动调用这个方法。重写以实现功能
func _enter():
	pass


## 退出这个节点任务时自动调用这个方法。重写以实现功能
func _exit():
	pass


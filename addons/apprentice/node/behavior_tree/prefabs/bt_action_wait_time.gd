#============================================================
#    Bt Action Wait Time
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-07 18:16:06
# - version: 4.0
#============================================================
## 等待一点时间。在等待时间内返回 [enum RUNNING]，结束后返回 [enum SUCCEED]
@icon("../icon/FTimer.png")
class_name BTActionWaitTime
extends BTActionEnterExit


## 执行完成
signal finished


## 等待时间
@export var time : BTResNumberValue
## 结束时间后返回的结果值
@export_enum("Succeed", "Failed") 
var return_result : int = 0


var _timer : Timer = Timer.new()
var _waiting : bool = false


#============================================================
#  内置
#============================================================
func _ready():
	_timer.one_shot = true
	_timer.timeout.connect(func(): 
		_waiting = false
		self.finished.emit()
	)
	add_child(_timer)


#============================================================
#  自定义
#============================================================
#(override)
func _enter():
	_waiting = true
	var t = time.get_value()
	Log.info(["等待", t, "秒"])
	_timer.start(t)


#(override)
func _exit():
	_timer.stop()


#(override)
func _task():
	super._task()
	if _waiting:
		return RUNNING
	return return_result

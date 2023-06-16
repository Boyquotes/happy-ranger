#============================================================
#    Bt Action Log
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-08 18:58:36
# - version: 4.0
#============================================================
## 输出日志
class_name BTActionLog
extends BTActionEnterExit


## 输出内容的阶段。在这个阶段的时候进行打印输出内容
@export_enum("Enter", "Exit", "Execute Task") 
var print_stage : int = 0
## 输出的内容
@export_multiline
var text : String


#(override)
func _enter():
	super._enter()
	_print(0)


#(override)
func _exit():
	super._exit()
	_print(1)


#(override)
func _do():
	_print(2)


func _print(stage):
	if print_stage == stage:
		Log.info([text])


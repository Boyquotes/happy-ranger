#============================================================
#    Action
#============================================================
# - datetime: 2023-02-05 00:41:58
#============================================================
class_name BTDoAction
extends BTActionLeaf


var _callable : Callable = func(): 
	pass


#(override)
func _do():
	_callable.call()


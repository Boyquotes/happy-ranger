#============================================================
#    Condition
#============================================================
# - datetime: 2023-02-05 00:43:03
#============================================================
class_name BTCondition
extends BTConditionLeaf


var _callable : Callable = func(): 
	return false


#(override)
func _do() -> bool:
	return _callable.call()


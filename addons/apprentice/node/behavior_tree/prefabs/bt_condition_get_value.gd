#============================================================
#    Bt Condition Get Value
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 16:30:21
# - version: 4.0
#============================================================
## 获取这个值的结果作为判断依据
class_name BTConditionGetValue
extends BTCondition


## 获取这个 key 的值，实际就是调用 [method BTRoot.get_global_value] 返回值
@export var key : String


#(override)
func _do() -> bool:
	return root.get_global_value(key, false)


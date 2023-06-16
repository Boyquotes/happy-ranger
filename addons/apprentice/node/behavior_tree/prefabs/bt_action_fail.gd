#============================================================
#    Bt Action Fail
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 23:32:33
# - version: 4.0
#============================================================
## 使这次执行失败，返回 [enum FAILED] 执行结果
class_name BTFail
extends BTActionLeaf


#(override)
func _task():
	return FAILED


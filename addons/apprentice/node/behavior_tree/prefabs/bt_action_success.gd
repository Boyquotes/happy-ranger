#============================================================
#    Bt Action Success
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 23:32:28
# - version: 4.0
#============================================================
## 使这次执行的结果成功。返回 [enum SUCCEED] 结果
class_name BTActionSuccess
extends BTActionLeaf


#(override)
func _task():
	return SUCCEED


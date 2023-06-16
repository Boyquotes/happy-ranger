#============================================================
#    Bt Action Expression Log
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 22:45:06
# - version: 4.0
#============================================================
## 输出日志
class_name BTActionExpressionLog
extends BTActionExpression


#(override)
func _do():
	Log.info( execute() )


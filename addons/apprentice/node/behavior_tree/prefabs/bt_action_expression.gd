#============================================================
#    Bt Action Log
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 22:42:27
# - version: 4.0
#============================================================
## 执行表达式功能
class_name BTActionExpression
extends BTActionLeaf


## 表达式内容。可以使用的变量有 [code]self[/code], [code]owner[/code], [code]root[/code],
##[code]data[/code], [code]target[/code]，其中
##[br]   [code]self[/code]  当前节点
##[br]   [code]owner[/code]  当前场景根节点
##[br]   [code]root[/code]  当前行为树的根节点
##[br]   [code]data[/code]  当前行为树的全局 [Dictionary] 数据，需要先调用
##[method BTRoot.set_global_value]  进行设置后才能获取
##[br]   [code]target[/code]  属性 [member target] 数据执行的节点对象
##[br]
##[br] 示例
##[codeblock] 
### 执行宿主的 attack 方法
##root.get_parent().attack()
##[/codeblock] 
@export_multiline var expression : String:
	set(v):
		expression = v
		_expression.parse(expression, ["self", "owner", "root", "data"])


var _expression : Expression = Expression.new()


#(override)
func _task():
	_do()
	return execute()


## 执行表达式
func execute():
	return _expression.execute([self, owner, root, root._data], self)


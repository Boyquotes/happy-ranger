#============================================================
#    Bt Condition Expression
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-07 17:40:09
# - version: 4.0
#============================================================
## 按照表达式执行结果进行条件判断，表达式结果需要是 [bool] 类型的值
class_name BTConditionExpression
extends BTCondition


## 表达式内容。可以使用的变量有 [code]self[/code], [code]owner[/code], [code]root[/code],
##[code]data[/code], [code]target[/code]，其中 
##[br]   [code]self[/code]  当前节点
##[br]   [code]owner[/code]  当前场景根节点
##[br]   [code]root[/code]  当前行为树的根节点
##[br]   [code]data[/code]  当前行为树的全局 [Dictionary] 数据，需要先调用
##[method BTRoot.set_global_value]  进行设置后才能获取
##[br]   [code]target[/code]  属性 [member target] 数据执行的节点对象
##[br]
##[br]获取返回全局数据
##[codeblock]
##data['has_player']
##[/codeblock]
##
##[br]计算位置距离是否足够
##[codeblock]
##data["self_pos"].distance_to(data["target_pos"]) < 100
##[/codeblock]
##
##[br]调用宿主的方法进行判断
##[codeblock]
##root.get_parent().can_attack()
##[/codeblock]
##
@export_multiline
var expression : String:
	set(v):
		expression = v
		_expression.parse(expression, ["self", "owner", "root", "data", "target"])
## 表达式中的 [code]target[/code] 对象
@export var target : Node


var _expression : Expression = Expression.new()


#(override)
func _do() -> bool:
	return execute()


## 执行表达式功能
##[br]
##[br][code]return[/code]  表达式返回的 [bool] 值
func execute() -> bool:
	return _expression.execute([self, owner, root, root._data, target], self)


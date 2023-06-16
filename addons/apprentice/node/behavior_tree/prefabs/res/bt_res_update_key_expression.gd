#============================================================
#    Bt Update Key Res
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 20:55:55
# - version: 4.0
#============================================================
class_name BTResUpdateKeyExpression
extends BTResUpdateKey


@export_multiline var expression : String:
	set(v):
		expression = v
		var err = _expression.parse(expression, ["owner", "self", "root", "data", "target"])
		if err != OK:
			Log.error(["expression 错误：", err, "(%s)" % error_string(err)])
@export var target : NodePath


var _expression : Expression = Expression.new()
var _target : Node


#(override)
func set_owner(owner):
	super.set_owner(owner)
	
	if not owner.is_inside_tree():
		await owner.tree_entered
	_target = owner.get_node_or_null(target)


#(override)
func get_value():
	return _expression.execute(
		[_owner, _owner, _owner.root, _owner.root._data, _target], 
		_owner
	)


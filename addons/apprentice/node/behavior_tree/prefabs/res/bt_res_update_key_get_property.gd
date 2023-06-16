#============================================================
#    Bt Action Update Key Res
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 20:52:44
# - version: 4.0
#============================================================
class_name BTResUpdateKeyGetProperty
extends BTResUpdateKey


@export var target : NodePath
@export var property : StringName


var _target : Node


#(override)
func set_owner(owner):
	super.set_owner(owner)
	if not owner.is_inside_tree():
		await owner.tree_entered
	_target = owner.get_node(target)


func get_value():
	return _target.get(property)


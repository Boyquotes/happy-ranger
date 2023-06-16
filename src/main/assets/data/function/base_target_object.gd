#============================================================
#    Base Directivity
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-22 14:59:03
# - version: 4.0
#============================================================
## 指向目标的
class_name BaseTargetObject
extends BaseFunction


@export var _target : NodePath:
	set(v):
		_target = v
		if role:
			if not role.is_inside_tree():
				await role.ready
			target_object = role.owner.get_node_or_null(_target)


var target_object : Object


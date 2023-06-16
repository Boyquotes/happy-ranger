#============================================================
#    Base Target Or Point
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-22 15:17:59
# - version: 4.0
#============================================================
## 目标为对象或点位
class_name BaseTargetObjectOrPoint
extends BaseFunction


@export var _target : NodePath:
	set(v):
		_target = v
		if role:
			if not role.is_inside_tree():
				await role.ready
			target_object = role.owner.get_node_or_null(_target)
@export var target_point : Vector2

var target_object : Object


## 自动获取方向
func auto_get_direction() -> Vector2:
	if target_object:
		return target_object.global_position.direction_to(role.global_position)
	elif target_point != Vector2.INF:
		return target_point.direction_to(role.global_position)
	else:
		return role.get_direction()


## 自动获取目标方向
func auto_get_target_position() -> Vector2:
	if target_object:
		return target_object.global_position
	else:
		return target_point


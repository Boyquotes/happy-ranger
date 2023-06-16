#============================================================
#    Input
#============================================================
# - datetime: 2023-02-28 23:49:02
# - version: 4.x
#============================================================
extends ConfigRole


@export var negative_x: StringName = "ui_left"
@export var positive_x: StringName = "ui_right"
@export var negative_y: StringName = "ui_up"
@export var positive_y: StringName = "ui_down"

@export var attack : StringName = "ui_accept"


#(override)
func _actor_ready():
	
	role.normal_process.connect(func(delta):
		var v = Vector2( Input.get_axis(negative_x, positive_x) , Input.get_axis(negative_y,positive_y) )
		role.move_direction(v)
		if Input.is_action_pressed(attack):
			role.cast_skill(Const.ATTACK)
		if v.y > 0:
			role.fall()
		
	)




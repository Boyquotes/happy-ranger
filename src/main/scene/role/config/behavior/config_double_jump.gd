#============================================================
#    Config Double Jump
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-07 23:33:08
# - version: 4.x
#============================================================
## 双跳
class_name ConfigDoubleJump
extends ConfigBehavior


@export var input_key_map : String = "ui_up"
@export var jump_height : float = 100
@export var interval : float = 0.5


var _second_jump_timer : Timer = NodeUtil.create_timer(interval, self)
var _in_second_stage : bool = false


#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	_second_jump_timer.one_shot = true
	
	if role.is_ground():
		get_listener().listen(role.jumped, func(height: float, data):
			if enabled:
				_second_jump_timer.start(interval)
				_in_second_stage = true
		)
	
	role.normal_process.connect(func(delta):
		if enabled:
			if _in_second_stage and _second_jump_timer.time_left == 0:
				if Input.is_action_pressed(input_key_map):
					role.jump(jump_height, true)
					_in_second_stage = false
			
			if role.is_on_floor_only():
				_in_second_stage = false
	)

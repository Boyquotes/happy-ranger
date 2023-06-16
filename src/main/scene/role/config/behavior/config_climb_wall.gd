#============================================================
#    Config Climb Wall
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-14 23:57:08
# - version: 4.0
#============================================================
## 爬墙
class_name ConfigClimbWall
extends ConfigBehavior



#(override)
func _set_enabled(value):
	enabled = value



#(override)
func _actor_ready():
	super._actor_ready()
	
	# 允许下次爬墙的时间
	var enabled_next_climb_wall = [true]
	var next_climb_wall_timer = NodeUtil.create_timer(0.65, self, func():
		enabled_next_climb_wall[0] = true
	, false, true)
	
	# 允许从地面上可以爬墙的时间间隔
	var enabled_first_climb_timer = NodeUtil.create_timer(0.3, self, Callable(), false, true)
	
	var last_on_wall = [false]
	role.normal_process.connect(func(delta):
		if enabled:
			if last_on_wall[0]:
				# 不在墙上重新设为 false
				if not role.is_on_wall_only():
					last_on_wall[0] = false
				
				if enabled_first_climb_timer.time_left == 0 and enabled_next_climb_wall[0]:
					if Input.is_action_pressed("ui_up"):
						role.jump(150, true)
						next_climb_wall_timer.start()
						enabled_next_climb_wall[0] = false
				
			else:
				if role.is_on_floor_only():
					enabled_first_climb_timer.start()
				if role.is_on_wall_only():
					last_on_wall[0] = true
			
	)
	


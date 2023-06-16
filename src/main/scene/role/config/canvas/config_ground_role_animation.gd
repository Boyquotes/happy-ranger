#============================================================
#    Animation
#============================================================
# - datetime: 2023-02-19 23:01:21
#============================================================
## 地面角色动画
class_name ConfigGroundRoleAnimation
extends ConfigCanvas


@export var idle : String = "idle"
@export var walk : String = "walk"
@export var jump : String = "jump"
@export var fall : String = "fall"
@export var hit : String = "hit"


var last_anim : String:
	set(v):
		if last_anim != v:
			last_anim = v
			role.play(last_anim)

var move_controller : PlatformController


#(override)
func _actor_ready():
	super._actor_ready()
	
	move_controller = role.move_controller as PlatformController
	if move_controller:
		get_listener().listen_all_state(func(previous, current, data):
			if current == Const.States.NORMAL:
				if role.is_on_floor_only():
					last_anim = (walk if move_controller.is_moving() else idle)
			
			elif current == Const.States.UNCONTROL:
				last_anim = idle
		
		, RoleListener.Priority.AFTER)
	else:
		Log.debug()
		Log.ln("%s", ["没有 PlatformController 类型的节点"])
		
	get_listener().listen(role.took_damage, func(data):
		if hit:
			last_anim = hit
	)
	


func _process(delta):
	if role.state_is_running(Const.States.NORMAL):
		
		# 在地面上则行播放动画
		if role.is_on_floor_only():
			last_anim = (walk if move_controller.is_moving() else idle)
		else:
			last_anim = (jump if not role.is_falling() else fall)
	


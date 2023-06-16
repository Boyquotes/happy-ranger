#============================================================
#    Config Tread
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-07 21:58:04
# - version: 4.x
#============================================================
## 头顶踩踏并跳跃（超级玛丽）
##
## TODO: 一点时间内不能超过一定次数，否则将会逐级出现对应惩罚性怪物，或者反弹随机弹到一边，防止滥用这个功能
class_name ConfigTread
extends ConfigBehavior


signal executed


@export var damage : float = 1.0
@export var jump_height : float = 64


var _jumped = {}


#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	var interval_timer := NodeUtil.create_timer(0.33, self)
	interval_timer.one_shot = true
	
	# 检测是否踩到
	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = Const.PhysicsLayer.ROLE
	CollisionUtil.create_rectangle_collision(Vector2(10, 10), area)
	role.add_to_canvas(area)
	
	const MIN_ANGLE = PI / 2 - PI / 6
	const MAX_ANGLE = PI / 2 + PI / 6
	
	get_listener().listen(area.area_entered, func(area):
		if not enabled or interval_timer.time_left > 0:
			return
		
		if (area is BodyArea 
			and area.host is Role
			and not role.is_on_floor_only() 
			and role.is_falling()
		):
			var target = area.host as Role
			if target == role or not role.is_can_control():
				return
			
			var angle = MathUtil.N.angle_to_point(role, area)
			if MathUtil.is_in_range(angle, MIN_ANGLE, MAX_ANGLE):
				# 记录，一段时间内不能再次碰撞伤害
				if _jumped.has(target) and not is_instance_valid(target):
					return
				_jumped[target] = null
				NodeUtil.create_once_timer(0.2, func(): _jumped.erase(target) , self)
				
				# 攻击
				role.attack(target, damage, { Const.TYPE: "tread" })
				if role.move_controller is PlatformController:
					role.move_controller.motion_velocity.y = 0
					role.jump(jump_height, true, { Const.TYPE: "tread" })
					self.executed.emit()
				
				interval_timer.start()
			
	)
	

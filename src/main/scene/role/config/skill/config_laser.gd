#============================================================
#    Config Laser
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-05 15:40:09
# - version: 4.x
#============================================================
## 激光攻击
class_name ConfigLaser
extends ConfigSkill


@export
var skill_name : String = "laser"
## 激光场景
@export
var laser_scene : PackedScene
## 最大度
@export
var distance_max : float = 64
## 每秒伤害值
@export_range(0, 10, 0.01, "or_greater", "suffix:/s")
var damage : float = 1.0
## 检测到的目标
@export_flags_2d_physics
var collision_mask : int = 1:
	set(v):
		collision_mask = v
		_cast_target.collision_mask = collision_mask
		_cast_wall.collision_mask = collision_mask
## 攻击施放激光的概率
@export
var probability : float = 0.3:
	set(v):
		probability = v
		_rand_probability.update_probability(probability)


var _rand_probability : RandomMinimumProbability = RandomMinimumProbability.new()
var _cast_target = CastTarget.new()
var _cast_wall = CastTarget.new()


func _ready():
	assert(laser_scene != null, "没有设置场景！")
	self.probability = probability


#(override)
func _actor_ready():
	# 攻击技能切换为施放激光
	get_listener().listen_skill(Const.ATTACK, func(stage, data):
		if stage == Const.Stages.READY:
			if not role.is_casting(skill_name) and _rand_probability.check():
				role.switch_cast_skill(Const.ATTACK, skill_name)
				Log.warning(["施放激光"])
	)
	
	# 激光部分
	_cast_target.collide_with_areas = true
	_cast_target.collide_with_bodies = false
	role.add_to_canvas(_cast_target)
	
	_cast_wall.collide_with_areas = false
	_cast_wall.collide_with_bodies = true
	_cast_wall.add_exception(role)
	role.add_to_canvas(_cast_wall)
	
	# 激光
	role.add_skill(skill_name, {
		Const.Stages.BEFORE: 0.2,
		Const.Stages.EXECUTE: 1.0,
		Const.Stages.AFTER: 0.2,
		Const.Stages.COOLDOWN: 2.0
	})
	
	var laser = laser_scene.instantiate()
	laser.modulate = Color.html("#cafff6")
	laser.visible = false
	laser.position = Vector2(4, 0)
	role.add_to_canvas(laser)
	get_listener().listen_skill(skill_name, func(stage, data):
		if stage == Const.Stages.EXECUTE:
			var duration = data[Const.Stages.EXECUTE]
			var interval = 0.1
			var delta_damage = interval / damage
			var count = int(duration / interval)
			
			var target_pos = role.global_position + role.get_direction() * distance_max
			laser.cast_to(target_pos)
			FuncUtil.execute_intermittent(interval, count, func():
				target_pos = role.global_position + role.get_direction() * distance_max
				# 射线检测发射到的位置
				var result = _cast_target.cast_to(target_pos)
				if result == Vector2.INF:
					result = _cast_wall.cast_to(target_pos)
				
				# 发射射线
				if result != Vector2.INF:
					cast_to(result, delta_damage)
				else:
					cast_to(target_pos, 0.0)
				
			)
			
			laser.visible = true
		
		else:
			laser.visible = false
		
	)
	
	get_listener().listen_skill_ended(skill_name, func():
		laser.visible = false
	)


func cast_to(target_pos: Vector2, damage: float):
	var body_area = _cast_target.get_collider() as BodyArea
	if body_area is BodyArea:
		var target = body_area.host
		if target is Role:
			target.take_damage({
				"damage": damage,
				"source": actor,
			})


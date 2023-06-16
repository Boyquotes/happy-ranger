#============================================================
#    Config Missile
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-07 14:37:38
# - version: 4.x
#============================================================
## 攻击投射物
##
##（这是一个比较特殊的节点，后续需要特殊设计）
class_name ConfigMissile
extends ConfigSkill


@export
var skill_name : String = "missile"
@export
var missile : PackedScene 


## 散弹概率
var _rand_probability = RandomMinimumProbability.new(0.5)


#(override)
func _actor_ready():
	super._actor_ready()
	
	role.add_skill(skill_name, {
		Const.Stages.BEFORE: 0.1,
		Const.Stages.EXECUTE: 0.3,
		Const.Stages.AFTER: 0.1,
		Const.Stages.COOLDOWN: 2,
	})
	
	assert(missile != null)
	
	var areas = role.node_db.get_nodes_by_class(Area2D)
	get_listener().listen_skill(skill_name, func(stage, data):
		if stage == Const.Stages.EXECUTE:
			var target = data.get(Const.TARGET)
			# TODO: 投射物
			assert(target != null, "没有传入 target 参数")
			
			var offset_rot = 0
			var count = 1
			
			if _rand_probability.check():
				count = 3
				offset_rot = -deg_to_rad(15) * count / 2.5 
			
			var to_target_dir = MathUtil.N.direction_to(role, target).rotated(-PI / 2)
			Projectile.create() \
				.add_to(Engine.get_main_loop().current_scene) \
				.set_position(role.global_position) \
				.set_life_time(2.0) \
				.set_rotation_to(target) \
				.forward(60) \
				.set_offset_rotation(offset_rot) \
				.set_array_offset_rotation(deg_to_rad(12)) \
				.add_custom_callback(func(projectile: Node2D, idx, total):
					if not is_instance_valid(role):
						return
					
					# 偏移
					if total > 1:
						var ratio = smoothstep( 0, total-1, idx )
						var pos = -to_target_dir * (ratio - 0.5) * total * 4
						projectile.global_position += pos
					
					# 投射物显示图形
					var m = missile.instantiate() as Node2D
					projectile.add_child(m)
					
					# 碰撞伤害
					var damage_area = RoleUtil.create_damage_area(role, Const.PhysicsLayer.ROLE | Const.PhysicsLayer.WALL)
					CollisionUtil.create_circle_collison(4, damage_area)
					for area in areas:
						damage_area.add_exception(area)
					
					# 检测碰撞到节点
					var enable = DataUtil.get_ref_data(true)
					damage_area.detected_node.connect(func(body, collision_shape):
						projectile.queue_free()
						if enable.value and body is BodyArea:
							enable.value = false
							if is_instance_valid(role):
								RoleUtil.handle_target_body_area(role, body, func(target: Role):
									var damage : float = 1.0
									role.attack(target, damage)
								)
					)
					projectile.add_child(damage_area)
					
					,
				) \
				.execute(count)
		
	)
	
	# 攻击触发方式
#	NodeUtil.create_timer(0.1, self, func():
#		if MathUtil.N.distance_to(role, Global.player) <= 60:
#			if role.is_can_cast_skill(skill_name):
#				role.cast_skill(skill_name, {
#					Const.TARGET: Global.player
#				})
#
#	, true)



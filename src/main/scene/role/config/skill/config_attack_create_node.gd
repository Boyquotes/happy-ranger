#============================================================
#    Config Attack Create Node
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-12 00:55:38
# - version: 4.x
#============================================================
## 攻击创建投射物
class_name ConfigAttackCreateNode
extends ConfigSkill


@export var skill_name : String = "attack_create_node"
@export var create_node : PackedScene
@export var projectile_pos : Marker2D
@export var probability : float = 1.0:
	set(v):
		probability = v
		rand_prob.update_probability(probability)


var rand_prob : RandomMinimumProbability = RandomMinimumProbability.new(1.0)


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen_skill(Const.ATTACK, func(stage, data):
		if stage == Const.Stages.READY:
			if rand_prob.check():
				var attack_unable_time : float = \
					role.get_skill_time(skill_name, Const.Stages.EXECUTE) \
					+ role.get_skill_time(skill_name, Const.Stages.AFTER) 
				role.switch_cast_skill(Const.ATTACK, skill_name, {}, attack_unable_time)
	)
	
	role.add_skill(skill_name, {
		Const.Stages.BEFORE: 0.1,
		Const.Stages.EXECUTE: 0.3,
		Const.Stages.AFTER: 0.1,
		Const.Stages.COOLDOWN: 0.0,
	})
	
	get_listener().listen_skill(skill_name, func(stage, data):
		if stage == Const.Stages.EXECUTE:
			Projectile.create() \
				.add_to(Engine.get_main_loop().current_scene) \
				.set_position(projectile_pos.global_position) \
				.set_rotation(role.get_direction().angle() + PI) \
				.set_life_time(1.0) \
				.forward(60) \
				.set_array_offset_rotation(deg_to_rad(12)) \
				.add_custom_callback(func(projectile: Node2D, idx, total):
					# 投射物显示图形
					var m = create_node.instantiate() as Node2D
					projectile.add_child(m)
					
					# 碰撞伤害
					var enable = DataUtil.get_ref_data(true)
					var damage_area = RoleUtil.create_damage_area(projectile, Const.PhysicsLayer.ROLE | Const.PhysicsLayer.WALL,
						func(body, collision_shape):
							if body is Area2D:
								projectile.queue_free()
							if enable.value and body is BodyArea:
								enable.value = false
								if is_instance_valid(role):
									RoleUtil.handle_target_body_area(role, body, func(target):
										var damage : float = 1.0
										role.attack(target, damage)
									)
					)
					# 添加碰撞形状
					var coll = CollisionUtil.create_circle_collison(4)
					damage_area.add_child(coll)
					projectile.add_child(damage_area)
					
					,
				) \
				.execute(1)
			
	)


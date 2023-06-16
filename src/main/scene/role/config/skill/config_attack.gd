#============================================================
#    Config Attack
#============================================================
# - datetime: 2023-03-05 13:52:52
# - version: 4.x
#============================================================
## 配置攻击
class_name ConfigAttack
extends ConfigSkill


const ATTACK_SKILL_NAME = "attack"


@export var ready_time : float = 0.0
@export var before_time : float = 0.0
@export var execute_time : float = 0.0
@export var after_time : float = 0.0
@export var cooldown_time : float = 0.0
@export var damage : float = 1.0
@export var damage_area : DamageArea


#(override)
func _actor_ready():
	super._actor_ready()
	
	if damage_area == null:
		var nodes = role.node_db.get_nodes_by_class(DamageArea)
		if nodes.size() == 1:
			damage_area = nodes[0]
		else:
			if nodes.is_empty():
				printerr("没有设置 ConfigAttack 的 damage_area 属性")
			else:
				printerr("有多个 DamageArea 节点")
			return null
	
	role.add_skill(ATTACK_SKILL_NAME, {
		Const.Stages.READY: ready_time,
		Const.Stages.BEFORE: before_time,
		Const.Stages.EXECUTE: execute_time,
		Const.Stages.AFTER: after_time,
		Const.Stages.COOLDOWN: cooldown_time,
	})
	
	# 攻击力属性
	get_listener().listen_property(Const.ATTACK, func(previous, current):
		if current != null:
			self.damage = current
	)
	
	# 攻击时重力会消失
	var platform_controller := role.get_first_node_by_class(PlatformController) as PlatformController
	get_listener().listen_skill(Const.ATTACK, func(stage, data):
		if stage == Const.Stages.BEFORE:
			platform_controller.motion_velocity.y = 0
			platform_controller.gravity_enabled = false
	)
	get_listener().listen_skill_ended(Const.ATTACK, func():
		platform_controller.gravity_enabled = true
	)
	
	# 攻击技能
	if damage_area:
		for area in role.node_db.get_nodes_by_class(Area2D):
			damage_area.add_exception(area)
		
		# 发出攻击时
		get_listener().listen_skill(ATTACK_SKILL_NAME, func(stage, data):
			match stage:
				Const.Stages.EXECUTE:
					damage_area.disabled = false
				Const.Stages.AFTER:
					damage_area.disabled = true
		)
		
		# 伤害盒碰到目标时
		get_listener().listen(damage_area.detected_node, func(target_body, collision_shape):
			if target_body is BodyArea:
				var target = target_body.host
				if is_instance_valid(target) and target != role:
					var result = role.attack(target, damage, {
						Const.TYPE: Const.DamageType.NORMAL,
					})
					damage_area.disabled = true
		)
		
	


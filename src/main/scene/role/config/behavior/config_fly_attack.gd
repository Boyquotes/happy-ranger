#============================================================
#    Config Fly Attack Player
#============================================================
# - datetime: 2023-02-21 11:02:19
#============================================================
## 飞行角色攻击 Player
class_name ConfigFlyAttackPlayer
extends ConfigBehavior


## 监听的执行的技能
@export var skill_name : String = ""
## 攻击距离 
@export_range(0.001, 100, 0.001, "or_greater", "hide_slider") var attack_distance : float = 8.0
## 攻击射线。判断能否攻击到目标
@export var attack_ray: RayCast2D
## 检测攻击目标区域。进入这个区域将会攻击目标
@export var detect_area : Area2D


#============================================================
#  自定义
#============================================================

#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	if Global.player == role:
		return
	
	assert(skill_name != "", str(role) + "没有设置攻击技能！")
	
	# 没有设置攻击区域，则
	var areas = role.node_db.get_nodes_by_class(DamageArea)
	for area in areas:
		attack_ray.add_exception(area)
	attack_ray.target_position = Vector2(-attack_distance, 0)
	
	# 更新攻击 
	var timer = NodeUtil.create_timer(0.2, self, func():
		if enabled and Global.player:
			var vector = MathUtil.N.diff_position(actor, Global.player)
			CanvasUtil.rotate_to(attack_ray, actor.global_position, Global.player.global_position)
	, true)
	
	get_listener().listen_all_state(func(previous, current, data):
		timer.paused = ( current != Const.States.NORMAL )
	)
	
	get_listener().listen_normal_process(func(delta):
		# 检测攻击
		if enabled and Global.player:
			if ((attack_ray.is_colliding() and attack_ray.get_collider() == Global.player )
				or MathUtil.N.distance_to( actor, Global.player ) <= attack_distance
			):
				if role.is_can_cast_skill(skill_name):
					role.cast_skill(skill_name, { Const.TARGET: Global.player })
			else:
				var dir = MathUtil.N.direction_to( actor, Global.player )
				role.move_direction( dir )
	)
	

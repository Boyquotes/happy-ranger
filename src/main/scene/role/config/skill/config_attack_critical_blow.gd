#============================================================
#    Config Attack Critical Blow
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-16 21:41:10
# - version: 4.0
#============================================================
## 攻击暴击
class_name ConfigAttackCriticalBlow
extends ConfigSkill


## 造成成倍伤害的概率
@export var probability : float = 0.0:
	set(v):
		probability = v
		random_probability.update_probability(probability)
## 造成实际伤害的倍数的伤害。这个是造成额外伤害，如果为0，则没有暴击伤害
@export_range(0, 10, 0.001, "or_greater")
var multiple : float = 1.0


var random_probability := RandomMinimumProbability.new(0.0)


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.attacked, func(data: Dictionary):
		# 对目标造成普通伤害时
		if data.get(Const.TYPE) == Const.DamageType.NORMAL:
			var target = data.get(Const.TARGET) as Role
			var real_damage = data.get(Const.REAL_DAMAGE, 0)
			# 随机概率造成暴击伤害
			if (target 
				and real_damage > 0 
				and random_probability.check()
				and multiple > 0
			):
				# 攻击目标
				var critical_blow_damage = real_damage * multiple
				var result = role.attack(target, critical_blow_damage, {
					Const.TYPE: Const.DamageType.CRITICAL_BLOW,
				})
				
				# 暴击伤害处理结果
				if result.get(Const.REAL_DAMAGE, 0) > 0:
					var d2 = result[Const.REAL_DAMAGE]
					# 伤害文字漂浮特效
					var label = FloatText.create( str(real_damage + d2), 
						target.global_position - Vector2(0, 8), 
						Vector2(0.5, 0.5)
					)
					label.modulate = Color.RED
					label.set("theme_override_colors/font_outline_color", Color.BLACK)
					label.set("theme_override_constants/outline_size", 1)
			
	)
	


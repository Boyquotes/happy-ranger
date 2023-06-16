#============================================================
#    Config Sprint Attack
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-06 22:43:46
# - version: 4.x
#============================================================
## 冲刺攻击
class_name ConfigSprintAttack
extends ConfigSkill


const SPRINT_ATTACK = "sprint_attack"

## 播放动画
@export var play_animation : String = "cast"
## 施放技能概率
@export var probability : float = 0.15:
	set(v):
		probability = v
		_rand_probability.set_probability(probability)
@export var damage_area : DamageArea
## 冲刺距离
@export var distance : float = 64.0


var _rand_probability := RandomMinimumProbability.new(probability)


#(override)
func _actor_ready():
	
	# 攻击技能切换
	get_listener().listen_skill(Const.ATTACK, func(stage, data):
		if stage == Const.Stages.READY:
			if not role.is_casting(SPRINT_ATTACK) and _rand_probability.check():
				var after_time = role.get_skill_time(SPRINT_ATTACK, Const.Stages.AFTER)
				role.switch_cast_skill(Const.ATTACK, SPRINT_ATTACK, {}, after_time)
				Log.info([ "冲刺攻击" ])
		
		Log.rich([ ">> attack", Const.Stages.keys()[stage] ], " ", Color.BLUE_VIOLET)
		
	)
	
	
	# 冲刺技能配置
	
	role.add_skill(SPRINT_ATTACK, {
		Const.Stages.BEFORE: 0.1,
		Const.Stages.EXECUTE: 0.25,
		Const.Stages.AFTER: 0.1,
		Const.Stages.COOLDOWN: 4,
	})
	
	get_listener().listen_skill(SPRINT_ATTACK, func(stage: int, data: Dictionary):
		if stage != Const.Stages.COOLDOWN:
			if play_animation:
				role.play(play_animation)
		if stage == Const.Stages.EXECUTE:
			if damage_area:
				damage_area.disabled = false
			
			role.move_controller.motion_velocity = Vector2(0,0)
			
			var duration = float(data[Const.Stages.EXECUTE])
			var velocity = role.get_direction() 
			velocity.x = sign(velocity.x)
			velocity.y = 0
			velocity *= distance / duration
			
			# 移动
			FuncUtil.apply_force(velocity, 10, func(state: FuncApplyForceState):
				role.velocity = state.get_velocity()
				role.move_and_slide()
			, role, duration)
			
			# 动画
			FuncUtil.execute_intermittent(0.03, duration / 0.03, func():
				var texture = role.anim_canvas.get_current_texture()
				if texture:
					var sprite = Sprite2D.new()
					sprite.texture = texture
					sprite.global_position = role.global_position
					sprite.scale = role.anim_canvas.scale
					sprite.offset = role.anim_canvas.get_offset()
					
					create_tween() \
						.tween_property(sprite, "modulate:a", 0.0, 0.25) \
						.finished.connect(sprite.queue_free)
					NodeUtil.add_node(sprite)
			)
			
		elif stage == Const.Stages.AFTER:
			if damage_area:
				damage_area.disabled = true
			
		
		if stage == Const.Stages.BEFORE:
			var move_controller = role.move_controller as PlatformController
			if move_controller:
				move_controller.gravity_enabled = false
		elif stage == Const.Stages.AFTER:
			var move_controller = role.move_controller as PlatformController
			if move_controller:
				move_controller.gravity_enabled = true
	)
	
	get_listener().listen_skill_ended(SPRINT_ATTACK, func():
		damage_area.disabled = true
	)
	


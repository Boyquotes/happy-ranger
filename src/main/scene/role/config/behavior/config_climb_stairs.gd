#============================================================
#    Config Climb Stairs
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-09 21:10:06
# - version: 4.0
#============================================================
## 爬墙
class_name ConfigClimbStairs
extends ConfigBehavior


## 攀爬速度
@export var climb_speed : float = 32


# 检测楼梯区域
var _detect_stairs : Area2D = Area2D.new()
# 没有楼梯时还有一点时间可以移动一点点
var _unable_timer : Timer = NodeUtil.create_timer(0.2, self, func():
	set_physics_process(false)
, false, true)
# 跳跃状态机根状态
var _state_root : StateNode = StateNode.new()


enum StateNames {
	Default,
	FirstJump,
	JumpDetectStairs,
	ClimbStairs,
}



#============================================================
#  自定义
#============================================================

#(override)
func _set_enabled(value):
	if enabled != value:
		enabled = value
		set_physics_process(enabled)
		
		if actor == null:
			return
		
		# 控制行为状态
		var platform_controller := get_actor().get_first_node_by_class(PlatformController) as PlatformController
		if platform_controller:
			platform_controller.jump_enabled = not enabled
			platform_controller.gravity_enabled = not enabled
			
			_unable_timer.stop()
			if enabled:
				platform_controller.motion_velocity.y = 0
			else:
				_unable_timer.start()


#(override)
func _actor_ready():
	super._actor_ready()
	
	var platform_controller := role.get_first_node_by_class(PlatformController) as PlatformController
	if platform_controller != null:
		
		# 添加检测楼梯
		_detect_stairs.monitorable = false
		_detect_stairs.collision_layer = 0
		_detect_stairs.collision_mask = Const.PhysicsLayer.STAIRS
		role.add_child(_detect_stairs)
		var collision = role.get_first_node_by_class(CollisionShape2D).duplicate()
		_detect_stairs.add_child(collision)
		
		# 默认状态
		var default = _state_root.add_state(StateNames.Default)
		# 跳跃后第一次按下“上”键
		var first_jump = _state_root.add_state(StateNames.FirstJump)
		# 开始检测是有楼梯
		var jump_detect_stairs = _state_root.add_state(StateNames.JumpDetectStairs)
		# 爬楼梯中
		var climb_stairs = _state_root.add_state(StateNames.ClimbStairs)
		
		_state_root.child_state_changed.connect(func(previous, current, data):
			pass
#			Log.debug()
#			printt(StateNames.keys()[previous], StateNames.keys()[current])
		)
		_state_root.auto_start = true
		
		# 默认状态
		default.auto_start = true
		default.listen_process(func(delta):
			if not role.is_on_floor_only():
				_state_root.trans_to_child(StateNames.FirstJump)
		)
		
		# 跳跃后第一次按下“上”键
		var _to_first_jump_timer : Timer = NodeUtil.create_timer(1, self)
		_to_first_jump_timer.one_shot = true
		first_jump.listen_enter(func(data: Dictionary):
			_to_first_jump_timer.stop()
			_to_first_jump_timer.start(0.5)
		)
		first_jump.listen_exit(_to_first_jump_timer.stop)
		first_jump.listen_process(func(delta: float):
			if _to_first_jump_timer.time_left <= 0 or role.is_falling():
				if Input.is_action_pressed("ui_up"):
					# 如果此时还在按向上跳，则切换到检测楼梯状态
					_state_root.trans_to_child(StateNames.JumpDetectStairs)
			elif Input.is_action_just_pressed("ui_up"):
				_state_root.trans_to_child(StateNames.JumpDetectStairs)
			
			if role.is_on_floor_only():
				_state_root.trans_to_child(StateNames.Default)
			
		)
		
		# 检测楼梯
		jump_detect_stairs.listen_enter(func(data: Dictionary):
			self._detect_stairs.area_entered.connect(func(area):
				_state_root.trans_to_child(StateNames.ClimbStairs)
			)
		)
		jump_detect_stairs.listen_exit(func():
			for data in _detect_stairs.area_entered.get_connections():
				_detect_stairs.area_entered.disconnect(data['callable'])
		)
		jump_detect_stairs.listen_process(func(delta: float):
			if role.is_on_floor_only():
				_state_root.trans_to_child(StateNames.Default)
		)
		
		# 开始爬楼梯
		climb_stairs.listen_enter(func(data: Dictionary):
			_detect_stairs.area_exited.connect(func(area):
				if role.is_on_floor_only():
					_state_root.trans_to_child(StateNames.Default)
				
				elif _detect_stairs.get_overlapping_areas() \
					.filter(func(area): return area is Stairs ) \
					.is_empty():
						# 周围没有楼梯了，则切换到默认
						_state_root.trans_to_child(StateNames.JumpDetectStairs)
			)
			role.unable_attack.incr()
			platform_controller.motion_velocity.y = 0
			platform_controller.gravity_enabled = false
			platform_controller.jump_enabled = false
		)
		climb_stairs.listen_exit(func():
			NodeUtil.disconnect_all(_detect_stairs.area_exited)
			platform_controller.gravity_enabled = true
			platform_controller.jump_enabled = true
			role.unable_attack.decr()
		)
		climb_stairs.listen_process(func(delta: float):
			# 上下移动
			role.velocity.x = 0
			role.velocity.y = Input.get_axis("ui_up", "ui_down") * climb_speed
			role.move_and_slide()
			if role.is_on_floor_only():
				_state_root.trans_to_child(StateNames.Default)
		)
		
		_state_root.name = "state_root"
		add_child(_state_root, true)
		
	

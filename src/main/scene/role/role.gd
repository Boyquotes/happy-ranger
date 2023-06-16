#============================================================
#    Role
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-13 13:16:06
# - version: 4.0
#============================================================
class_name Role
extends CharacterBody2D


## normal 状态执行线程
signal normal_process(delta: float)
## 已发出攻击
signal attacked(data: Dictionary)
## 将要受到伤害
signal will_be_take_damage(data: Dictionary)
## 已遭受到伤害
signal took_damage(data: Dictionary)
## 已死亡
signal died(data: Dictionary)
## 状态已切换
signal child_state_changed(previous: StringName, current: StringName, data: Dictionary)
## 移动方向已发生改变
signal direction_changed(direction: Vector2)
## 已跳跃
signal jumped(height: float, data: Dictionary)
## 将目标击杀
signal killed_target(data: Dictionary)


# 功能节点
var __init_node__ = FuncUtil.inject_by_unique(self)
var anim_canvas : AnimationCanvas
var body_area : BodyArea
var node_db : NodeDB
var property_management : PropertyManagement
var buff_management : BuffManagement
var item_management : DataManagement
var state_node : StateNode
var skill_actuator : SkillActuator
var role_listener : RoleListener
var projectile_pos : Marker2D
var config : FRoot
var move_controller : MoveController


## 是否不能施放技能
var unable_cast := PropertyWrapper.wrap_property(
	func(v): property_management.set_property(Const.UNABLE_CAST, v),
	func(): return property_management.get_property(Const.UNABLE_CAST, 0)
)
# 施放技能
var unable_attack := PropertyWrapper.wrap_property(
	func(v): property_management.set_property(Const.UNABLE_ATTACK, v),
	func(): return property_management.get_property(Const.UNABLE_ATTACK, 0)
)

var _prop_uncontrol := PropertyWrapper.wrap_property(
	func(value):
		property_management.set_property(Const.UNABLE_CONTROL, value)
		_update_state(),
	func(): return property_management.get_property(Const.UNABLE_CONTROL, false)
)
func _update_state():
	if _prop_uncontrol.get_as_bool():
		if get_state() == Const.States.NORMAL:
			trans_to_child(Const.States.UNCONTROL)
	else:
		if get_state() == Const.States.UNCONTROL:
			trans_to_child(Const.States.NORMAL)

var _uncontrol_timer :  = TimerExtension.new()
var _died : bool = false
var _jumped_data: Dictionary = {}
var _unable_skill : Dictionary = {}


#============================================================
#  SetGet
#============================================================
## 获取技能控制对象
func get_skill_actuator() -> SkillActuator:
	return skill_actuator

## 能否施放这个技能
func is_can_cast_skill(skill_name: StringName) -> bool:
	return (
		skill_actuator.is_can_execute(skill_name)
		and not unable_cast.get_as_bool()
		and not _unable_skill.has(skill_name)
	)

## 当前是否为正常(normal)状态
func is_normal_state() -> bool:
	return state_node.child_state_is_running(Const.States.NORMAL)

## 是否正在施放这个技能
func is_casting(skill_name: String) -> bool:
	return skill_actuator.is_executing(skill_name)

## 是否是可控制的
func is_can_control():
	return (
		move_controller != null
		and state_node.child_state_is_running(Const.States.NORMAL)
		and not _prop_uncontrol.get_as_bool()
	)

## 获取当前状态
func get_state():
	return state_node.get_current_child_state()

## 是否这个动画
func has_animation(animation: StringName) -> bool:
	return anim_canvas.has_animation(animation)

## 是否是死亡的
func is_died() -> bool:
	return _died
#	var health = get_property(Const.HEALTH, 0)
#	return snapped(health, 0.01) <= 0

## 获取节点朝向
func get_direction() -> Vector2:
	var dir = move_controller.get_direction()
	if dir == Vector2.ZERO:
		return Vector2.RIGHT
	return dir

## 是否是地面单位
func is_ground() -> bool:
	return move_controller is PlatformController

## 获取属性值
func get_property(property, default = null):
	return property_management.get_property(property, default)

## 是否正在落下
func is_falling() -> bool:
	return not is_on_floor_only() and move_controller.motion_velocity.y > 1

## 获取第一个这个类型的节点
func get_first_node_by_class(_class) -> Node:
	return node_db.get_first_node_by_class(_class)

## 设置面向方向
func set_direction(direction: Vector2) -> void:
	move_controller.update_direction(direction)

## 是否正在执行
func state_is_running(state_name:StringName) -> bool:
	return state_node.child_state_is_running(state_name)

## 获取技能时间
##[br]
##[br][code]skill_name[/code]  技能名称
##[br][code]stage[/code]  阶段
##[br][code]return[/code]  返回技能的时间，如果没有这个阶段，则会返回 -1 
func get_skill_time(skill_name: StringName, stage: int) -> float:
	return skill_actuator.get_skill_data(skill_name).get(stage, -1.0)

## 获取技能总时间
func get_skill_time_total(skill_name: StringName) -> float:
	var data = skill_actuator.get_skill_data(skill_name)
	return data.get(Const.Stages.READY, 0) \
		+ data.get(Const.Stages.EXECUTE, 0) \
		+ data.get(Const.Stages.AFTER, 0) \
		+ data.get(Const.Stages.COOLDOWN, 0)


#============================================================
#  内置
#============================================================
func _ready():
	_init_signal()
	_init_property()


#============================================================
#  私有的
#============================================================
func _init_signal():
	# 不可控制的时间
	add_child(_uncontrol_timer)
	_uncontrol_timer.started.connect( _prop_uncontrol.incr )
	_uncontrol_timer.timeout.connect( _prop_uncontrol.decr )
	
	# 技能执行
	role_listener.listen(skill_actuator.started
	, func(skill_name: StringName):
		var skill_data = skill_actuator.get_skill_data(skill_name)
		state_node.trans_to_child(Const.States.SKILL, skill_data)
	)
	
	# 信号连接信号
	SignalUtil.connect_signal(state_node.child_state_changed, self.child_state_changed)
	
	# 技能终止
	var skill_discontinue_callable : Callable = func():
		# 不能有其他正在施放的技能
		var not_end_stage_count : int = 0
		for sname in skill_actuator.get_executing_skills():
			if skill_actuator.get_skill_stage(sname) < Const.Stages.COOLDOWN:
				not_end_stage_count += 1
		# 没有正在施放的技能则切换到普通状态
		if not_end_stage_count == 0:
			if _prop_uncontrol.get_as_bool():
				trans_to_child(Const.States.UNCONTROL)
			else:
				trans_to_child(Const.States.NORMAL)
	role_listener.listen(skill_actuator.ended
		, func(skill_name: StringName):
			skill_discontinue_callable.call()
	, Listener.Priority.AFTER)
	
	# 到达设置的结束状态的段，切换到 normal
	role_listener.listen(skill_actuator.stage_changed 
		, func(skill_name: StringName, stage_idx: int, data: Dictionary):
			var stage_name = skill_actuator.get_stage_name(stage_idx) 
			if (stage_name == Const.Stages.COOLDOWN):
				skill_discontinue_callable.call()
	)
	
	# 控制移动
	move_controller = node_db.get_first_node_by_class(MoveController)
	if move_controller is PlatformController:
		move_controller.host = self
	
	if move_controller:
		move_controller.moved.connect(func(vector):
			self.velocity = vector
			self.move_and_slide()
		)
		property_management.listen_property(Const.MOVE_SPEED,
			func(previous, current):
				move_controller.move_speed = current
		)
		if move_controller is PlatformController:
			move_controller.jumped.connect(func(height: float):
				self.jumped.emit(height, _jumped_data)
				_jumped_data.clear()
			)
		SignalUtil.connect_signal(move_controller.direction_changed, self.direction_changed)
	
	# 物品属性追加到玩家上
	role_listener.listen(item_management.newly_added_data, func(id, data: Dictionary):
		FuncUtil.for_dict(data, func(key, value):
			if property_management.has_property(key):
				if value is int or value is float:
					property_management.add_property(key, value)
	))
	role_listener.listen(item_management.data_changed, func(id, previous, current):
		FuncUtil.for_dict(current, func(key, value):
			if property_management.has_property(key):
				if value is int or value is float:
					property_management.add_property(key, value - previous.get(key, 0) )
	))
	role_listener.listen(item_management.removed_data, func(id, data):
		FuncUtil.for_dict(data, func(key, value):
			if property_management.has_property(key):
				if value is int or value is float:
					property_management.sub_property(key, value)
	))
	
	role_listener.listen(self.died
	, func(data):
		trans_to_child(Const.States.UNCONTROL, {
			Const.TYPE: "died"
		})
	)
	
	# 属性监听
	property_management.listen_property(Const.GROUP, func(previous, current):
		if current:
			Group.add(current, self)
		else:
			Group.remove(previous, self)
	)
	
	node_db.newly_node.connect(func(node):
		if node is BodyArea:
			node.collision_layer = 1 << 1
			node.collision_mask = 0
		
		elif node is DamageArea:
			node.collision_layer = 0
			node.collision_mask = 1 << 1
			
	)
	


func _init_property():
	# 状态机
	for state in Const.States.values():
		state_node.add_state(state)
	state_node.enter_child_state(Const.States.NORMAL)
	state_node.get_child_state_node(Const.States.NORMAL).state_processed.connect(
		func(delta):
			self.normal_process.emit(delta)
	)
	
	# 技能
	skill_actuator.set_stages(Const.Stages.values())
	# 属性
	var data = {
		Const.HEALTH: 3,
		Const.HEALTH_MAX: 3,
	}
	for p in data:
		property_management.add_property(p, data[p])



#============================================================
#  公共的
#============================================================
##  添加角色配置节点
##[br]
##[br][code]config_node[/code]  配置节点 
func add_config(config_node: ConfigRole) -> void:
	self.config.add_child(config_node)


##  初始化角色数据
##[br]
##[br][code]data[/code]  属性数据
func init_property(data: Dictionary) -> void:
	for prop in data:
		property_management.set_property(prop, data[prop])


## 将节点添加到 Canvas 中
func add_to_canvas(node: Node) -> void:
	anim_canvas.add_child(node)


## 施放技能
##[br]
##[br][code]skill_name[/code]  技能名称
##[br][code]additional[/code]  技能附加数据
##[br][code]force[/code]  强制施放技能
func cast_skill(skill_name: StringName, additional: Dictionary = {}, force: bool = false) -> void:
	if skill_actuator.has_skill(skill_name):
		if skill_name == Const.ATTACK and not force:
			if unable_attack.get_as_bool():
				return
		
		if force:
			skill_actuator.stop(skill_name)
		if is_normal_state() and (is_can_cast_skill(skill_name) or force):
			skill_actuator.execute(skill_name, additional)
		
	else:
		Log.error(['没有', skill_name, "技能！"])


##  切换施放技能。用于打断技能换为施放其他技能
##[br]
##[br][code]from_skill_name[/code]  打断的技能
##[br][code]to_skill_name[/code]  切换到的技能
##[br][code]additional[/code]  技能附加数据
##[br][code]from_skill_unable_time[/code]  让这个技能不可用的长，如果低于0，则不设置
func switch_cast_skill(
	from_skill_name: String, 
	to_skill_name: String, 
	additional: Dictionary = {},
	from_skill_unable_time: float = 0.0
) -> void:
	if _unable_skill.has(to_skill_name):
		return
	if is_can_cast_skill(to_skill_name):
		if from_skill_unable_time > 0:
			_unable_skill[from_skill_name] = null
			NodeUtil.create_once_timer(from_skill_unable_time, func():
				_unable_skill.erase(from_skill_name)
			, self)
		assert(from_skill_name != to_skill_name, "两个技能名称不能相同！")
		stop_skill(from_skill_name, true)
		role_listener.prevent_signal(skill_actuator.stage_changed)
		cast_skill(to_skill_name, additional, true)


##  停止执行的技能
##[br]
##[br][code]skill_name[/code]  技能名称。如果不传入，默认停止当前执行的技能
##[br][code]immediate_cooldown[/code]  立即进入冷却状态，默认为如果正在执行的技能就进入 after 状态
func stop_skill(skill_name: StringName = &"", immediate_cooldown: bool = false) -> void:
	if skill_name == &"" and not skill_actuator.get_executing_skills().is_empty():
		skill_name = skill_actuator.get_executing_skills().front()
	
	if skill_name != &"" and skill_actuator.has_skill(skill_name):
		if (
			skill_actuator.is_in_stage(skill_name, Const.Stages.READY)
			or skill_actuator.is_in_stage(skill_name, Const.Stages.BEFORE)
		):
			# 还未正式执行能时
			skill_actuator.stop(skill_name)
		
		elif skill_actuator.is_in_stage(skill_name, Const.Stages.EXECUTE):
			# 正在执行技能时
			if immediate_cooldown:
				skill_actuator.goto_stage(skill_name, Const.Stages.COOLDOWN)
			else:
				skill_actuator.goto_stage(skill_name, Const.Stages.AFTER)
		
		elif skill_actuator.is_in_stage(skill_name, Const.Stages.AFTER):
			if immediate_cooldown:
				skill_actuator.goto_stage(skill_name, Const.Stages.COOLDOWN)
		


##  使角色不可控制
##[br]
##[br][code]time[/code]  不可控时间
##[br][code]type[/code]  时间叠加类型。参见 [enum TimerExtension.TimeType]
func make_uncontrol(time: float, type : TimerExtension.TimeType = TimerExtension.TimeType.MAX) -> void:
	# 不可控制状态时的数据
	if time > 0:
		_uncontrol_timer.start(time, type)


##  移动方向
##[br]
##[br][code]direction[/code]  方向
func move_direction(direction: Vector2) -> void:
	if is_can_control():
		move_controller.move_direction(direction.normalized())


##  移动向量
##[br]
##[br][code]vector[/code]  移动向量值
func move_vector(vector: Vector2) -> void:
	if is_can_control():
		move_controller.move_vector(vector)


##  添加技能
##[br]
##[br][code]skill_name[/code]  技能名称
##[br][code]data[/code]  技能数据
func add_skill(skill_name: String, data: Dictionary):
	if not data.has(Const.NAME):
		data[Const.NAME] = skill_name
	skill_actuator.add_skill(skill_name, data)


##  添加 buff
##[br]
##[br][code]buff_name[/code]  Buff 名称
##[br][code]data[/code]  buff 相关数据
##[br][code]executor[/code]  功能执行器对象
##[br][code]return[/code]  返回buff控制方式处理对象
func add_buff(
	buff_name: String, 
	data : Dictionary,
	executor: FuncUtil.BaseExecutor,
):
	data['name'] = buff_name
	if buff_management == null: await ready
	buff_management.execute(buff_name, data, executor)


##  播放动画
##[br]
##[br][code]animation[/code]  动画名称
func play(animation: StringName) -> void:
	if anim_canvas.has_animation(animation):
		anim_canvas.play(animation)


##  跳跃。移动节点为 [PlatformController] 类型时才有用
##[br]
##[br][code]height[/code]  跳跃高度
##[br][code]force[/code]  是否强制跳跃。如果为 [code]true[/code] 节点在空中时也能跳跃
func jump(height: float = 0, force: bool = false, data: Dictionary = {}) -> void:
	if move_controller is PlatformController:
		if height == 0:
			height = move_controller.jump_height
		_jumped_data = data
		move_controller.jump(height, force)


## 落下
func fall():
	# 地面角色
	if move_controller is PlatformController:
		var layer : int  = collision_mask & Const.PhysicsLayer.FLOOR
		if layer > 0:
			collision_mask -= layer
			await get_tree().create_timer(0.1).timeout
			collision_mask |= Const.PhysicsLayer.FLOOR


## 切换状态
##[br]
##[br][code]state_name[/code]  状态名
##[br][code]data[/code]  传入数据
func trans_to_child(state_name, data: Dictionary ={}) -> void:
	if not state_node.child_state_is_running(state_name):
		state_node.trans_to_child(state_name, data)


## 添加物品。返回这个物品数据的 id
func add_item(data: Dictionary) -> String:
	var item_id = DataManagement.get_id(data, ["name", "level"])
	if item_management.has_data(item_id):
		var origin_data = item_management.get_data(item_id) as Dictionary
		# 叠加数据
		var new_data = JsonUtil.dict_add(origin_data, data)
		item_management.set_data(item_id, new_data)
	else:
		item_management.add_data(item_id, data.duplicate())
	return item_id


## 拿取物品。将角色身上的物品取出
##[br]
##[br][code]item_id[/code]  物品ID
##[br][code]count[/code]  物品数量
##[br][code]return[/code]  返回拿取到的量的物品数据
func take_item(item_id: String, count: int) -> Dictionary:
	if item_management.has_data(item_id):
		var data = item_management.get_data(item_id) as Dictionary
		var total = data.get(Const.COUNT, 0)
		if total == 0:
			return {}
		
		var take_count := int( count if total > count else total )
		data[Const.COUNT] = total - take_count
		if data[Const.COUNT] == 0:
			item_management.remove_data(item_id)
		
		var take_data = data.duplicate()
		take_data[Const.COUNT] = take_count
		return take_data
	return {}


## 攻击到目标。一般为伤害区域碰到敌人后，调用这个方法对这个目标造成伤害
##[br]
##[br][code]target[/code]  攻击目标
##[br][code]damage[/code]  攻击伤害
##[br][code]data[/code]  攻击伤害数据
##[br][code]return[/code]  返回攻击处理后的数据
##[br]
##[br]若要控制角色攻击敌人，执行 [code]cast_skill("attack")[/code] 开始进行攻击流程
func attack(target, damage: float, data: Dictionary = {}) -> Dictionary:
	var damage_data = Dictionary(data)
	damage_data[Const.TARGET] = target
	damage_data[Const.DAMAGE] = damage 
	damage_data[Const.SOURCE] = self
	if is_instance_valid(target):
		damage_data.merge(target.take_damage(damage_data))
	self.attacked.emit(damage_data)
	
	# 击杀目标
	if damage_data.get(Const.TARGET_HEALTH, 0) <= 0:
		var kill_data : Dictionary = {}
		kill_data[Const.TARGET] = target
		kill_data[Const.DAMAGE] = damage
		kill_data[Const.SOURCE] = self
		self.killed_target.emit(kill_data)
	
	return damage_data


##  受到伤害
##[br]
##[br][code]damage_data[/code]  伤害数据
##[br][code]return[/code]  返回伤害处理后的数据
func take_damage(damage_data: Dictionary) -> Dictionary:
	var damage = damage_data.get(Const.DAMAGE, 0)
	ErrorLog.is_zero(damage, "没有设置伤害值")
	self.will_be_take_damage.emit(damage_data)
	if not is_died():
		var health = property_management.get_property(Const.HEALTH, 0)
		if damage > health:
			damage = health
		
		health -= damage
		# 防止精度缺失判断失误（防止输出显示为 0，但是 if 判断时要比 0 大的情况）
		health = snappedf(health, 0.01)
		property_management.set_property(Const.HEALTH, health)
		
		# 动画效果
		Log.info([self, "受到伤害抖动: damage = ", damage, ", health = ", health, ", data = ", damage_data])
		EffectUtil.hit(anim_canvas, Color.RED, 0.08, 0.16, 4, Color.WHITE)
		EffectUtil.shock(anim_canvas, 0.5, 40, Vector2(0, 0))
		
		# 伤害数据
		var data : Dictionary = Dictionary(damage_data)
		data[Const.REAL_DAMAGE] = damage
		self.took_damage.emit(data)
		data[Const.TARGET_HEALTH] = health
		
		# 状态控制
		if is_zero_approx(health):
			_died = true
			if is_instance_valid(body_area):
				body_area.disabled = true
			trans_to_child(Const.States.UNCONTROL, { Const.TYPE: "die" })
			make_uncontrol(INF, TimerExtension.TimeType.COVER)
			self.died.emit(data)
			
			Log.error([ self, "死亡" ])
			
		else:
			make_uncontrol(0.5, TimerExtension.TimeType.MAX)
		
		return data
		
	else:
		Log.warning(["目标已死亡"])
	
	return Dictionary(damage_data)


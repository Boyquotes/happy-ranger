#============================================================
#    Config Ground Patrol
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-12 19:10:08
# - version: 4.x
#============================================================
## 让节点左右随机游荡
class_name ConfigGroundPatrol
extends ConfigBehavior


## 开始移动到下一个位置
signal moved_next


## 下一次移动时会随机选择一个方向移动
@export var random_direction : bool = true
## 移动距离
@export var move_distance : ResValue
@export var has_floor : RayCast2D
@export var has_wall : RayCast2D
## 更新判断地形的间隔时间
@export_range(0, 0.2, 0.001)
var update_time : float = 0.1
## 到达目标位置时判定的距离，在这个距离内则代表到达了目标位置
@export var arrive_distance : float = 8.0


var _next_move_timer : Timer = NodeUtil.create_timer(2, self, Callable(), true)
var _move_to : MoveTo = MoveTo.new()
var _last_changed_direction : bool = false


#============================================================
#  自定义
#============================================================
#(override)
func _set_enabled(value):
	if enabled != value:
		enabled = value
		if enabled:
			start_next()
		else:
			_next_move_timer.stop()
			_move_to.stop()


#(override)
func _actor_ready():
	super._actor_ready()
	
	# 不检测当前节点
	for area in role.node_db.get_nodes_by_class(Area2D):
		if has_floor:
			has_floor.add_exception(area)
		if has_wall:
			has_wall.add_exception(area)
	
	if has_floor:
		has_floor.collision_mask = Const.PhysicsLayer.FLOOR | Const.PhysicsLayer.WALL
		has_floor.add_exception(role)
	if has_wall:
		has_wall.collision_mask = Const.PhysicsLayer.WALL
		has_wall.add_exception(role)
	
	# 随机面向方向
	update_direction( [Vector2.LEFT, Vector2.RIGHT].pick_random() )
	
	# 移动到目标位置方法
	_move_to.arrive_distance = arrive_distance
	role.add_to_canvas(_move_to)
	_move_to.moved.connect(func(direction: Vector2): 
		direction.y = 0
		role.move_direction(direction) 
	)
	_move_to.arrived.connect( start_next )
	_next_move_timer.timeout.connect( func(): _move_to.to(_get_move_to_pos()) )
	
	# 状态切换时
	get_listener().listen_all_state(func(previous, current, data):
		if current == Const.States.NORMAL:
			start_next()
		else:
			_next_move_timer.stop()
			_move_to.stop()
	)
	
	# 更新移动方向
	NodeUtil.create_timer(update_time, self, func():
		if enabled:
			# 没有路者有墙则反向移动
			if _check_change_direction():
				_move_to.stop()
				update_direction( role.get_direction() * Vector2(-1, 1) )
	, true)
	
	
	if enabled:
		start_next()
	


func update_direction(direction: Vector2) -> void:
	if role.get_direction() != direction:
		role.set_direction(direction)
		_last_changed_direction = true


func start_next() -> void:
	if not _next_move_timer.is_inside_tree():
		await _next_move_timer.ready
	_next_move_timer.stop()
	_next_move_timer.start(_get_next_move_time())
	self.moved_next.emit()


func _check_change_direction() -> bool:
	return (
		(has_floor and not has_floor.is_colliding()) 
		or (has_wall and has_wall.is_colliding())
	)


func _get_next_move_time() -> float:
	return 2.0


func _get_move_to_pos() -> Vector2:
	var d = ([-1, 1].pick_random() if random_direction else 1)
	if _check_change_direction():
		d = -1
	elif _last_changed_direction:
		d = 1
	
	_last_changed_direction = false
	return (role.global_position 
		+ Vector2(role.get_direction().x, 0) 
		*  move_distance.get_value()
		* d
	)


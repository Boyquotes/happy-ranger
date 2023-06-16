#============================================================
#    Base Function
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-22 14:37:11
# - version: 4.0
#============================================================
@tool
class_name BaseFunction
extends Resource


## 准备执行
signal ready_executed
## 已开始执行
signal executed
## 执行完成
signal finished


## 图像
@export var texture : Texture2D
## 名称
@export var name : String = ""
## 描述
@export_multiline var description : String = ""
## 延迟执行
@export var delay_time : float = 0.0
## 执行持续时间。如果设置的时间小于 0，则值为 INF
@export var duration : float = 0.0:
	set(v):
		duration = v
		if duration < 0:
			duration = INF
## 是否显示这个状态
@export var showed : bool = true

var role : Object


## 有生命时间的
class LifespanTimer:
	extends Timer
	
	var callable : Callable
	
	func _init(callable):
		self.callable = callable
	
	func _physics_process(delta):
		if callable.is_valid():
			callable.call()
		else:
			self.queue_free()


#============================================================
#  自定义
#============================================================
##  具体执行功能。用于重写
func _execute() -> void:
	pass


## 执行功能
func execute() -> void:
	if delay_time > 0:
		create_once_timer(delay_time, func():
			self.ready_executed.emit()
			_execute()
			self.executed.emit()
		)
	else:
		_execute()


## 发送完成信号
func emit_finish() -> void:
	self.finished.emit()


## 绑定使用对象
func bind_role(role : Node) -> void:
	if self.role != role:
		self.role = role


##  创建一个一次性计时器
##[br]
##[br][code]time[/code]  时间
##[br][code]callable[/code]  回调方法
##[br][code]to[/code]  添加到这个节点上，如果为 null，则自动添加到当前场景
##[br][code]return[/code]  返回创建的 [Timer]
func create_once_timer(
	time: float = 1.0, 
	callable: Callable = Callable()
) -> Timer:
	var timer := Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.timeout.connect(timer.queue_free)
	if callable.is_valid():
		timer.timeout.connect(callable)
	
	(role \
		if role \
		else Engine.get_main_loop().current_scene
	).add_child(timer)
	return timer


## 执行一次性
func execute_once(
	callback: Callable, 
	delay: float = 0, 
	finish_callback: Callable = Callable()
) -> void:
	if delay > 0:
		create_once_timer(delay, func():
			callback.call()
			finish_callback.call()
		)
	else:
		callback.call()
		if finish_callback.is_valid():
			finish_callback.call()


## 执行一段时间
func execute_duration_process(
	duration: float,
	callback: Callable, 
	finish_callback: Callable = Callable()
) -> void:
	assert(duration > 0, "持续时间必须超过 0，若想永远执行，请传入参数值为 INF")
	
	var timer := LifespanTimer.new(callback)
	timer.wait_time = duration \
		if duration > 0 \
		else INF
	timer.one_shot = true
	timer.autostart = true
	if finish_callback.is_valid():
		timer.timeout.connect(finish_callback)
	timer.timeout.connect(timer.queue_free)
	role.add_child(timer)


## 执行每间隔时间执行一下
func execute_interval_process(
	duration, 
	interval, 
	callback: Callable,
	finish_callback: Callable = Callable()
) -> void:
	if duration == 0:
		callback.call()
		return
	
	var time : Array = [0]
	var delta : float = Engine.get_main_loop().root.get_physics_process_delta_time()
	execute_duration_process(duration
	, func():
		time[0] += delta
		if time[0] > interval:
			time[0] -= interval
			callback.call()
	, finish_callback
	)


## 执行次数
func execute_count_process(
	count: int,
	interval: float,
	callback: Callable,
	finish_callback: Callable = Callable(),
):
	assert(count >= 0, "执行次数不能小于 0")
	assert(interval >= 0, "间隔时间不能小于 0")
	
	var time : float = interval * count
	if count == int(INF):
		time = INF
	if duration > 0:
		time = min(duration, time)
	
	if time == 0:
		for i in count:
			callback.call()
		finish_callback.call()
	
	else:
		execute_interval_process(
			time
			, interval
			, callback
			, finish_callback
		)
	

#============================================================
#    Behavior Tree Root
#============================================================
# - datetime: 2022-09-14 01:05:47
#============================================================

## 行为树根节点。只会执行第一个 bt 节点，所以一般下面会添加一个 [Selector] 节点
@icon("../icon/FBehaviorTreeRoot.png")
class_name BTRoot
extends Node


## 数据发生改变
##
##[br][code]key[/code] 改变数据的 key
##[br][code]previous[/code] 之前的值
##[br][code]current[/code] 当前的值
signal data_changed(key, previous, current)


## 当前执行的线程的类型
enum ProcessCallback {
	PHYSICS = Timer.TIMER_PROCESS_PHYSICS, ## 物理线程 
	IDLE = Timer.TIMER_PROCESS_IDLE, ## 普通线程
}


## 这个行为树是否执行
@export var enable : bool = true :
	set(v):
		enable = v
		__update_process()
## 线程执行方式
@export var process_callback : ProcessCallback = ProcessCallback.PHYSICS :
	set(v):
		process_callback = v
		__update_process()


var _delta := 0.0
var _data := {}

var _leafs := []
var _first : Node:
	set(v):
		assert(v != null)
		_first = v


#============================================================
#  扫描子节点
#============================================================
class Scanner:
	## 扫描所有子孙节点
	static func _scan(node: Node, list: Array, condition: Callable):
		list.append_array(node.get_children().filter(condition))
		for child in node.get_children():
			_scan(child, list, condition)
	
	static func scan(node: Node, condition: Callable) -> Array:
		var list = []
		_scan(node, list, condition)
		return list


#============================================================
#  SetGet
#============================================================
##  用于子节点获取执行线程的间隔时间
func get_delta_time() -> float:
	return _delta

## 获取这个树的全局数据
func get_global_value(property, default = null):
	return _data.get(property, default)

## 设置这个树的全局数据
func set_global_value(property, value):
	var previous = _data.get(property)
	_data[property] = value
	if previous != value:
		self.data_changed.emit(property, previous, value)


#============================================================
#  内置
#============================================================
func _enter_tree():
	var childs = Scanner.scan(self, func(node): return node is BTLeaf)
	for child in childs:
		child.root = self
	__update_process()
	
#	var base_script = DataUtil.singleton("__behavior_tree_BTBase_script", func(): 
#		return load(ScriptUtil.get_object_script_path(self).get_base_dir().path_join("bt_base.gd"))
#	)
#	# 扫描筛选出带有 root 属性的节点
#	_leafs = Scanner.scan(self, func(node: Node): return is_instance_of(node, base_script) )
#	for child in _leafs:
#		if "root" in child:
#			child.root = self
#	__update_process()
	
	for child in get_children():
		if is_instance_of(child, BTNode):
			_first = child
			break


func _ready():
	__update_process()


func _process(delta):
	_delta = delta
	_first._task()


func _physics_process(delta):
	_delta = delta
	_first._task()


#============================================================
#  自定义
#============================================================
func __update_process():
	set_physics_process(false)
	set_process(false)
	if process_callback == 0:
		set_physics_process(enable) 
	else:
		set_process(enable)


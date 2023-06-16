#============================================================
#    Maker
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 10:43:18
# - version: 4.0
#============================================================
## 制造机
class_name Maker
extends Node2D


## 创建了一个节点
signal created(node: Node)
## 已达到最大值
signal maximum_reached


@export var enabled : bool = true:
	set(v): enabled = v; set_process(enabled)
@export var scene : PackedScene
@export_range(0.001, 100, 0.001, "or_greater", "hide_slider") var interval : float = 1.0
## 最大创建数量
@export_range(-1, 100, 1, "or_greater", "hide_slider") var max_count : int = -1
@export var create_to : CanvasItem


var _count : int = 0
var _t : float = 0.0


func _ready():
	_check()


func _process(delta):
	_t += delta
	if _t > interval:
		_t -= interval
		_execute()


func _check():
	if enabled and (_count < max_count or max_count == -1) and scene:
		set_process(true)
	else:
		set_process(false)
		_t = 0


func _execute():
	var instance = scene.instantiate()
	_count += 1
	instance.tree_exiting.connect(func(): _count -= 1, Object.CONNECT_ONE_SHOT)
	if create_to and instance is CanvasItem:
		instance.global_position = create_to.global_position
	NodeUtil.add_node(instance)
	self.created.emit(instance)
	if max_count >= 0 and _count >= max_count:
		self.maximum_reached.emit()

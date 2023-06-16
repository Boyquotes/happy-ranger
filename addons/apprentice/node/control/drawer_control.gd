#============================================================
#    Drawer Control
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-29 12:50:27
# - version: 4.0
#============================================================
## 当前暂时只测试了从左开始的位置
class_name DrawerControl
extends Control


signal finished(state)


enum {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM,
}


## 从这个位置开始运动
@export_flags("Left", "Right", "Top", "Bottom") 
var from_direction : int = LEFT


var _actor : Control


#============================================================
#  内置
#============================================================
func _init(actor: Control = null):
	if actor:
		set_actor(actor)
	custom_minimum_size = Vector2.ZERO
	size = Vector2.ZERO
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _enter_tree():
	var p_size : Vector2
	if get_parent() is Control:
		p_size = get_parent().size
	else:
		p_size = get_viewport_rect().size
	self.size = p_size
	self.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	if from_direction == LEFT:
		self.position.x = -self.size.x
		self.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	elif from_direction == RIGHT:
		self.position.x = self.size.x
		self.grow_horizontal = Control.GROW_DIRECTION_END
	elif from_direction == BOTTOM:
		self.position.y = -self.size.y
		self.grow_vertical = Control.GROW_DIRECTION_END
	elif from_direction == TOP:
		self.position.y = self.size.y
		self.grow_vertical = Control.GROW_DIRECTION_BEGIN


#============================================================
#  自定义
#============================================================
func _update_default_actor_pos():
	if from_direction == LEFT:
		_actor.position.x = -_actor.size.x
	elif from_direction == RIGHT:
		_actor.position.x = self.size.x
	elif from_direction == TOP:
		_actor.position.y = -_actor.size.y
	elif from_direction == BOTTOM:
		_actor.position.y = self.size.y


func set_actor(actor: Control) -> void: 
	_actor = actor
	if actor:
		if not is_inside_tree():
			await ready
		if not actor.is_inside_tree():
			add_child(actor)
			_update_default_actor_pos()

func get_actor() -> Control:
	return _actor

func get_position_from():
	match from_direction:
		LEFT: return -_actor.size.x
		RIGHT: return self.size.x
		TOP: return -_actor.size.y
		BOTTOM: return self.size.y

func get_position_to():
	match from_direction:
		LEFT: return 0
		RIGHT: return self.size.x - _actor.size.x
		TOP: return 0
		BOTTOM: return self.size.y - _actor.size.y

func get_size_axle():
	match from_direction:
		LEFT, RIGHT: return "custom_minimum_size:y"
		TOP, BOTTOM: return "custom_minimum_size:x"

func get_position_axle():
	match from_direction:
		LEFT, RIGHT: return "position:x"
		TOP, BOTTOM: return "position:y"


func execute(state: bool, duration: float = 0.2) -> DrawerControl:
	if not _actor:
		print("没有 actor 节点")
		return self
	
	if not self.is_inside_tree():
		await self.ready
	
	var tween := create_tween()
	if state:
		# 伸出
		self.set_indexed.call_deferred("size:y", get_position_from())
		tween.parallel().tween_property(_actor, get_position_axle(), get_position_to(), duration)
		tween.parallel().tween_property(self, get_size_axle(), _actor.size.y, duration)
	else:
		# 缩入
		tween.parallel().tween_property(_actor, get_position_axle(), get_position_from(), duration)
		tween.parallel().tween_property(self, get_size_axle(), 0, duration)
	
	tween.finished.connect(func(): 
		self.finished.emit(state) 
	)
	return self


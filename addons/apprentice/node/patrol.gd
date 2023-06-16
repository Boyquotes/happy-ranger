#============================================================
#    Patrol
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-08 11:35:16
# - version: 4.0
#============================================================
class_name Patrol
extends Node2D


signal moved(pos: Vector2)
signal stopped
signal finished


@export var distance : NumberValue
@export var time : NumberValue
@export var arrive_distance : float :
	set(v):
		arrive_distance = v
		_arrive_distance_squar = pow(arrive_distance, 2)


var _arrive_distance_squar : float 
var _target_pos : Vector2
var _starting : bool = false:
	set(v):
		if _starting != v:
			_starting = v
			if _starting:
				_update_target_pos()
			set_physics_process(_starting)


func _physics_process(delta):
	if global_position.distance_squared_to(_target_pos) < _arrive_distance_squar:
		_starting = false
		finished.emit()


func _update_target_pos():
	_target_pos = global_position \
		+ (Vector2.LEFT.rotated(randf_range(-PI, PI)) * distance.get_value())


func get_last_target_position() -> Vector2:
	return _target_pos


func start():
	_starting = true
	moved.emit(_target_pos)


func stop():
	_starting = false


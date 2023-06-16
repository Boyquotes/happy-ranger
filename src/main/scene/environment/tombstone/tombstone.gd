#============================================================
#    Tombstone
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-13 14:55:59
# - version: 4.0
#============================================================
## 墓碑
class_name Tombstone
extends Area2D


## 等级发生改变
signal level_changed(previous: float, current: float)


## 当前生命值
@export_range(0, 100.0, 0.001, "or_greater", "hide_slider")
var health : float = 1.0:
	set(v): health = v; _update_property()
## 最大生命值
@export_range(0, 100.0, 0.001, "or_greater", "hide_slider")
var max_health : float = 100.0:
	set(v): max_health = v; _update_property()
## 生长速度
@export_range(0, 100.0, 0.001, "or_greater", "hide_slider", "suffix:health / s") 
var grow : float = 0.1
## 不同阶段等级的生命占比
##[br]例如：[code]0, 0.25, 0.5, 0.75[/code]，则在命发生改变时计算 [code]health/health_max[/code]，
##超过 [code]0[/code] 则为 1 级，超过[code]0.25[/code]则为 2 级
@export var stage_level : String = "0, 0.25, 0.5, 0.75":
	set(v): stage_level = v; _update_property()


@onready var _anim_spr_previous = %anim_spr_previous
@onready var _anim_spr_current = %anim_spr_current
@onready var _stage_progress = %StageProgress as StageProgress


var _tween : Tween
var _time : float = 0.0


#============================================================
#  内置
#============================================================
func _ready():
	self.stage_level = stage_level
	_anim_spr_previous.modulate.a = 0.0
	_anim_spr_current.modulate.a = 1.0


func _process(delta):
	_time += delta
	if _time >= 1:
		_time = 0.0
		health += grow


#============================================================
#  自定义
#============================================================
func _update_property():
	if _stage_progress == null: await ready
	_stage_progress.stage_ratio = stage_level
	_stage_progress.max_value = max_health
	_stage_progress.value = health


#============================================================
#  连接信号
#============================================================
func _on_step_progress_stage_changed(previous: int, current: int):
	if _anim_spr_current == null: await ready
	
	_anim_spr_previous.frame = previous
	_anim_spr_previous.modulate.a = 1.0
	_anim_spr_current.frame = current
	
	var duration : float = 1.0
	if is_instance_valid(_tween):
		_tween.stop()
	_tween = create_tween()
	if current > previous:
		_anim_spr_current.show_behind_parent = false
		_anim_spr_current.modulate.a = 0.0
		_tween.tween_property(_anim_spr_current, "modulate:a", 1.0, duration)
	else:
		_anim_spr_current.show_behind_parent = true
		_anim_spr_current.modulate.a = 1.0
		_tween.tween_property(_anim_spr_previous, "modulate:a", 0.0, duration)
	_tween.chain().tween_callback(func(): _anim_spr_previous.modulate.a = 0.0 )


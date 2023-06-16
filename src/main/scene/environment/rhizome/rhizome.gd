#============================================================
#    Rhizome
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-14 00:36:13
# - version: 4.0
#============================================================
## 根茎
class_name Rhizome
extends EnvironmentArea



## 当前高度
@export_range(0, 100, 0.001, "or_greater", "hide_slider", "suffix:px") var height : float = 16.0:
	set(v):
		if height != v:
			height = v
			if sprite_2d == null: await ready
			sprite_2d.size = Vector2(16, height)
			sprite_2d.position = Vector2(0, 16 - height)
## 生长时的增长高度
@export_range(0, 100, 0.001, "or_greater", "hide_slider") var grow_speed : float = 0.1
## 生长周期，每隔这段时间将会生长一次
@export_range(0.001, 100, 0.001, "or_greater", "hide_slider", "suffix:s") var cycle : float = 10:
	set(v):
		cycle = v
		if grow_timer == null: await ready
		grow_timer.wait_time = cycle


@onready var sprite_2d = $Sprite2D
@onready var grow_timer = $grow_timer


#============================================================
#  自定义
#============================================================
func _ready():
	self.height = height
	grow_timer.wait_time = cycle
	grow_timer.start(cycle)


#============================================================
#  连接信号
#============================================================
func _on_grow_timer_timeout():
	height += grow_speed

#============================================================
#    Chest
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-26 00:55:07
# - version: 4.0
#============================================================
## 宝箱
class_name Chest
extends Area2D


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var gpu_particles_2d = $GPUParticles2D
@onready var collision_shape_2d = $CollisionShape2D


var items : Array[BaseItemData] = []


#============================================================
#  内置
#============================================================
func _ready():
	area_entered.connect(func(area):
		if area is BodyArea:
			open(area.host)
	)


#============================================================
#  自定义
#============================================================
func add_item(item):
	items.append(item)


func open(role):
	collision_shape_2d.set_deferred("disabled", true)
	
	await NodeUtil.create_once_timer(0.1, Callable(), self).timeout
	animated_sprite_2d.play("treasure")
	
	# TODO: 有额外特殊道具时播放粒子动画
	await NodeUtil.create_once_timer(0.3, Callable(), self).timeout
	if is_instance_valid(self):
		gpu_particles_2d.restart()
	
	await Engine.get_main_loop().create_timer(0.4).timeout
	Datas.pop_goods_node(items, self.global_position + Vector2(0, -12))


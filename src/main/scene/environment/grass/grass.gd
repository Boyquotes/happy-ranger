#============================================================
#    Grass
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-16 19:30:47
# - version: 4.0
#============================================================
class_name Grass
extends EnvironmentArea


var anim_index : int = 0:
	set(v):
		anim_index = v
		if not is_inside_tree():
			await ready
		animated_sprite_2d.frame = anim_index
var role : Node2D


@onready var animated_sprite_2d = %AnimatedSprite2D
@onready var wind_area = $WindArea


func _ready():
	wind_area.area_entered.connect(func(node):
		if (RoleUtil.is_player_body_area(node) 
			and is_instance_valid(role)
			and not role.is_inside_tree()
		):
			assert(role!=null, "创建的时候必须要设置 role 值")
			Engine.get_main_loop().current_scene.add_child.call_deferred(role)
			role.global_position = self.global_position + Vector2(8, 8)
	)
	anim_index = randi_range(0, 3)


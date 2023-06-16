#============================================================
#    Config Canvas Flip
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-07 12:21:31
# - version: 4.x
#============================================================
## 左右移动时画面翻转
class_name ConfigCanvasFlip
extends ConfigCanvas


const DIR = [
	Vector2.LEFT, Vector2.RIGHT, 
	Vector2.UP, Vector2.DOWN
]


## 图片默认面向方向
@export_enum("Left", "Right", "Up", "Down") 
var default_diretion : int = 0


#(override)
func _actor_ready():
	super._actor_ready()
	
	var move_controller = role.get_first_node_by_class(MoveController)
	assert(move_controller != null, "没有添加 MoveController 类型节点")
	
	update_direction(role.get_direction())
	get_listener().listen(role.direction_changed, update_direction)


## 更新面向方向
func update_direction(direction: Vector2):
	if direction.x != 0:
		direction *= DIR[default_diretion]
		direction = direction.sign()
		direction.y = 1
		role.anim_canvas.set_flip(direction)


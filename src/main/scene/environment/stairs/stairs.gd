#============================================================
#    Stairs
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-09 22:06:24
# - version: 4.0
#============================================================
@tool
class_name Stairs
extends Area2D


const LENGTH : int = 16		# 每格长度


@onready var image : NinePatchRect = $image
@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var shape := collision.shape as RectangleShape2D


func grow(direction: Vector2i, length: int) -> void:
	if not is_inside_tree(): 
		await ready
	
	assert(direction in [Vector2i.UP, Vector2i.DOWN], "必须是 UP 或 DOWN 方向")
	
	var height = abs(direction.y) * length * LENGTH
	image.size.y = height
	if direction == Vector2i.UP:
		image.position.y = -height
	shape.size.y = height
	collision.position.y = float(height) / 2 * sign(direction.y) 



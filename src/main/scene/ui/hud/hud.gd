#============================================================
#    Hud
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-14 17:19:56
# - version: 4.x
#============================================================
class_name HUD
extends CanvasLayer


#============================================================
#  SetGet
#============================================================
static func has_hud() -> bool:
	return get_instance() != null


static func get_instance() -> HUD:
	return NodeUtil.get_tree().get_first_node_in_group(&"hud")


#============================================================
#  内置
#============================================================
func _init():
	add_to_group(&"hud")


func _ready():
	pass
#	$virtual_joystick.visible = (OS.get_name() in ["Android", "iOS"])


#============================================================
#  连接信号
#============================================================
func _on_virtual_joystick_analogic_process(direction: Vector2, strength: float):
	if direction != Vector2.ZERO and strength > 0.3:
		var angle : float = abs(direction.angle())
		var dir : Vector2 = direction.sign()
		if MathUtil.is_in_range(angle, deg_to_rad(80), deg_to_rad(100)) and strength > 0.8:
#			printt("UP", strength)
			dir.x = 0
		elif MathUtil.is_in_range(angle, deg_to_rad(40), deg_to_rad(140)) and strength > 0.65:
#			printt("LEFT_RIGHT_UP", strength)
			pass
		else:
#			printt("LEFT_RIGHT", strength)
			dir.y = 0
		
		dir.y *= -1
		
		if dir.y >= 0:
			if dir.y > 0:
				InputUtil.action_once_press("ui_up")
			if dir.x < 0:
				InputUtil.action_once_press("ui_left")
			elif dir.x > 0:
				InputUtil.action_once_press("ui_right")
			
		else:
			InputUtil.action_once_press("ui_down")
		

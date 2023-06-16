#============================================================
#    Function Test
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 17:56:20
# - version: 4.0
#============================================================
extends Node2D


@export var function : BaseFunction


@onready var execute = $Execute
@onready var executor = FunctionInstantiate.new(execute, function)


func _physics_process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var angle = get_global_mouse_position().angle_to_point(ControlUtil.get_center(execute))
		var params = FunctionDataUtil.missile_data(
			null, 
			get_global_mouse_position(), 
			angle, 
			Vector2.LEFT.rotated(angle) * 100,
		)
		executor.execute(params, null, get_global_mouse_position())


func _on_execute_pressed():
	var angle = get_global_mouse_position().angle_to_point(execute.global_position + execute.size / 2)
	executor.execute({
		"create_position": get_global_mouse_position(),
		"velocity": Vector2.LEFT.rotated(angle) * 100,
		"rotation": angle
	}, null, get_global_mouse_position())


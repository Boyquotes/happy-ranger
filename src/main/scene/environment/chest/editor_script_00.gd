# editor_script_00.gd
@tool
extends EditorScript


func _run():
	pass
	
	var velocity = Vector2.UP.rotated(-PI * randf() / 2) * randf_range(32, 64)
	print_debug(velocity)


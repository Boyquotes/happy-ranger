# editor_script_00.gd
@tool
extends EditorScript


func _run():
	pass
	
	var root = EditorUtil.get_edited_scene_root()
	
	var node = BTExpressionUtil.parse("""
if data:
	pass

""", root, ["data"])
	
	var code = (node.get_script() as GDScript).source_code
	print(code)
	
	print(node.host)
	


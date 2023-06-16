# editor_script_00.gd
@tool
extends EditorScript


func _run():
	pass
	
	var file = CollectionPanelDataFile.instance("res://.godot/collection_panel/test.gdata")
	
	print(file.get_data())
	


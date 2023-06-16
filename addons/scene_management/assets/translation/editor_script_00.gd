# editor_script_00.gd
@tool
extends EditorScript


func _run():
	pass
	
	var tr = TranslationUtil.load_traslation_file("res://addons/scene_management/assets/translation/tra.csv")
	tr.set_default_locale("zh")
	print(tr.get_message("ADD"))
	


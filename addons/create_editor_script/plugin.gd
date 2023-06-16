#============================================================
#    Plugin
#============================================================
# 点击菜单：项目 > 工具 > 创建 EditorScript 脚本
# 即可在选中的目录下创建 EditorScript 脚本
#============================================================
# - datetime: 2023-02-07 20:24:19
#============================================================
@tool
extends EditorPlugin


const MENU_NAME = "创建 EditorScript 脚本"


func _enter_tree() -> void:
	add_tool_menu_item(MENU_NAME, func():
		var path = get_selected_path()
		if not DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_recursive_absolute(path)
		
		var filepath = ""
		var idx = 0
		while true:
			filepath = path.path_join("editor_script_%02d.gd" % idx)
			if not FileAccess.file_exists(filepath):
				var script = GDScript.new()
				script.source_code = """# %s
@tool
extends EditorScript


func _run():
	pass
	

""" % filepath.get_file()
				ResourceSaver.save(script, filepath)
				await get_tree().process_frame
				get_editor_interface().get_resource_filesystem().scan()
				get_editor_interface().get_file_system_dock().navigate_to_path(filepath)
				script.reload()
				get_editor_interface().edit_script(load(filepath), 7)
				
				break
			idx += 1
		
	)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_NAME)


func get_selected_path() -> String:
	var list = get_editor_interface().get_selected_paths()
	if len(list) > 0:
		var path = list[0] as String
		if FileAccess.file_exists(path):
			path = path.get_base_dir()
		return path
	else:
		push_warning("没有选中目录或文件")
	return ""



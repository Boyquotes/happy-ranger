#============================================================
#    Plugin
#============================================================
# - datetime: 2022-09-14 23:44:24
#============================================================

@tool
extends EditorPlugin


const AUTO_LOAD_NAME = "FNodeGlobal"

const F_NODE_GLOBAL = "res://addons/fnode_v2/src/common/FNodeGlobal.gd"


# 自定义类
var custom_type_data := {}
# 类名对应的图标
var class_name_to_icon_map := {}
# 当前路径
var current_path := get_script().resource_path.get_base_dir() as String 
# 图标所在路径
var icon_path := current_path.path_join("/src/asset/icon")
# 默认图标
var default_icon := get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")



#============================================================
#  内置
#============================================================
func _enter_tree() -> void:
	await get_tree().process_frame
	
	add_autoload_singleton(AUTO_LOAD_NAME, F_NODE_GLOBAL)
	
	# 加载脚本
	print("[ FNode ] 开始加载数据")
	print("[ FNode ] 图标路径：", icon_path)
	
	var files : Array = FFileScanner.scan( get_script().resource_path.get_base_dir().path_join("/src/core"))
	var scripts : Array = files.map(func(file): 
		return load(file)
	)
	for fclass in scripts:
		var cname = fclass.resource_path.get_file().get_basename()
		# 查看是否有这个文件
		var path := icon_path.path_join(cname + ".png")
		if FileAccess.file_exists(path):
			var icon := load(path) as Texture
			if icon is Texture:
				# 根据类名作为图标的 Key
				class_name_to_icon_map[cname] = icon
	
	print("[ FNode ] 添加自定义类")
	# 添加自定义类
	for fclass in scripts:
		if fclass.get_instance_base_type() == "Node":
			# 类名
			var cname = fclass.resource_path.get_file().get_basename()
			custom_type_data[cname] = fclass
			# 图标，查找图标
			var icon : Texture = find_icon(fclass)
			# 添加自定义类
			add_custom_type(cname, "Node", fclass, icon)


func _exit_tree() -> void:
	remove_autoload_singleton(AUTO_LOAD_NAME)
	for cname in custom_type_data:
		remove_custom_type(cname)



#============================================================
#  自定义
#============================================================
func find_icon(fclass: Script) -> Texture:
	var cname : String 
	while fclass:
		cname = fclass.resource_path.get_file().get_basename()
		if class_name_to_icon_map.has(cname):
			return class_name_to_icon_map[cname]
		fclass = fclass.get_base_script()
	return default_icon





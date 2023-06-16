#============================================================
#    Collection Panel Utils
#============================================================
# - datetime: 2022-10-02 09:09:23
#============================================================
class_name CollectionPanelUtils
extends Object


const CACHE_PATH = "res://.godot/collection_panel/cache.gdata"


var plugin : EditorPlugin


var class_to_node_map := {
		"CanvasItemEditor": null,
		"Node3DEditor": null,
		"ScriptEditor": null,
		"EditorAssetLibrary": null,
		"CPUParticles3DEditor": null,
		"GPUParticles3DEditor": null,
		"MeshInstance3DEditor": null,
		"MeshLibraryEditor": null,
		"MultiMeshEditor": null,
		"Skeleton2DEditor": null,
		"Sprite2DEditor": null,
		"NavigationMeshEditor": null,
	}


#============================================================
#  SetGet
#============================================================
func get_editor_interface() -> EditorInterface:
	return plugin.get_editor_interface()

##  获取当前编辑器的编辑类型（2D、3D、Script、AssetLib）
func get_main_screen_editor() -> String:
	if class_to_node_map.CanvasItemEditor == null:
		# 扫描子节点
		var main_screen = get_editor_interface().get_editor_main_screen()
		for child in main_screen.get_children():
			var class_ = child.get_class()
			if class_to_node_map.has(class_):
				class_to_node_map[class_] = child
	
	# 2D
	if class_to_node_map.CanvasItemEditor.visible:
		return "2D"
	# 3D
	if class_to_node_map.Node3DEditor.visible:
		return "3D"
	# Script
	if class_to_node_map.ScriptEditor.visible:
		return "Script"
	# AssetLib
	if class_to_node_map.EditorAssetLibrary.visible:
		return "AssetLib"
	return ""


#============================================================
#  自定义
#============================================================
static func instance() -> CollectionPanelUtils:
	return DataUtil.singleton(&"collection_panel_utils", func():
		var instance = CollectionPanelUtils.new()
		instance.plugin = EditorPlugin.new()
		return instance
	) as CollectionPanelUtils



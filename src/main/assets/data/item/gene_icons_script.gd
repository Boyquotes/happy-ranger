#============================================================
#    Gene Icons Script
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-15 23:01:15
# - version: 4.0
#============================================================
@tool
extends EditorScript


func _run():
	# 当前场景
	var root = get_editor_interface().get_edited_scene_root()
	# 选中的节点
	var select_nodes = get_editor_interface().get_selection().get_selected_nodes()
	var parent : Node = root
	if select_nodes.size() > 0:
		parent = select_nodes[0]
	
#	for child in parent.get_children():
#		child.queue_free()
	
	var create_node = func(texture: Texture2D):
		var node = TextureRect.new()
		node.texture = texture
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.custom_minimum_size = Vector2(16, 16)
		return node
	
	# 扫描这个目录文件，添加到当前打开的场景选中的节点中
	var icon_path = "res://src/main/assets/texture/used/item/treasure/"
	var offset : Vector2i = Vector2i(32, 32)
	var max_count : int = 10
	var files = FileUtil.scan_file(icon_path, true)
	var count = DataUtil.get_ref_data(0)
	FuncUtil.foreach(files, func(file: String, idx: int):
		if file.get_extension() == "png":
			var icon = load(file)
			if icon is Texture2D:
				var node = create_node.call(icon)
				var x = (count.value % max_count) 
				var y = int(count.value / max_count)
				node.global_position = Vector2i(x, y) * offset
				parent.add_child(node, true)
				node.owner = root
				count.value += 1
	)
	
	print("finished")
	



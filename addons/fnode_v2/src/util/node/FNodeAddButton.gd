##============================================================
##    F Node Add Button
##============================================================
## - datetime: 2022-10-01 20:41:20
##============================================================
#@tool
#class_name FNodeAddButton
#extends Object
#
#
#var plugin: EditorPlugin
#var hbox := HBoxContainer.new()
#var state_line_text := LineEdit.new()
#var add_state_button := Button.new()
#var extend_script_button := Button.new()
#
#
##============================================================
##  SetGet
##============================================================
#func get_editor_interface() -> EditorInterface:
#	return plugin.get_editor_interface()
#
#func get_tree() -> SceneTree:
#	return get_editor_interface().get_tree()
#
#
##============================================================
##  内置
##============================================================
#func _init(_plugin: EditorPlugin):
#
#	assert(_plugin.is_inside_tree(), "插件必须要添加到场景中")
#
#	self.plugin = _plugin
#
#	# 获取场景编辑部分的节点
#	var data = (get_editor_interface()
#		.get_file_system_dock()
#		.get_parent_control()
#		.get_parent_control()
#	)
#	# SceneTreeDock 左上角添加编辑场景节点的部分，这个其实就是一个 VBox 垂直列表
#	var scene_tree_dock = data.get_child(0).get_child(0)
#	# SceneTreeEditor 场景节点树部分
#	var scene_tree_editor : Control
#	for child in scene_tree_dock.get_children():
#		if child.get_class() == "SceneTreeEditor":
#			scene_tree_editor = child
#			break
#
#	# 上方的几个按钮容器
##	var scene_tree_button_container = scene_tree_dock.get_children()[0]
#
#	# 底部新增列表
#	state_line_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
#	state_line_text.placeholder_text = "StateNode Name"
#
#	add_state_button.text = "Add StateNode"
#	add_state_button.pressed.connect(add_state)
#
#	extend_script_button.text = "Extend Script"
#	extend_script_button.pressed.connect(extend_script)
#
#	hbox.add_child(state_line_text)
#	hbox.add_child(add_state_button)
#	hbox.add_child(extend_script_button)
#	scene_tree_dock.add_child(hbox)
#
#
#
##============================================================
##  自定义
##============================================================
### 安装到这个插件上
#static func install(plugin: EditorPlugin) -> FNodeAddButton:
#	var instance = FNodeAddButton.new(plugin)
#	return instance
#
### 卸载
#func uninstall():
#	hbox.queue_free()
#	get_tree().create_timer(0.1).timeout.connect(func(): self.free())
#
### 获取 base_state.gd 脚本
#func get_base_state_script_path() -> String:
#	var scene_root = get_editor_interface().get_edited_scene_root() as Node
#	if scene_root == null:
#		printerr("当前场景没有节点，不能自动添加节点")
#		return ""
#	if not FileAccess.file_exists(scene_root.scene_file_path):
#		printerr("当前场景没有保存，不能自动添加节点")
#		return ""
#
#	var base_state_script_path
#	var path = scene_root.scene_file_path.get_base_dir()
##	if not scene_root is FStateRoot:
##		# 场景根节点不是 FStateRoot 类型
##		# 则需要创建在这个场景目录下的 state_machine 目录下创建脚本
##		# 加载的脚本为 base_state.gd 脚本
##		path = path.path_join("state_machine")
##		base_state_script_path = path.path_join("base_state.gd")
##	else:
##		base_state_script_path = (FState as Script).resource_path
##
#	return base_state_script_path
#
#
#func get_state_script(base_state_script: Script, state_path: String) -> GDScript:
#	if FileAccess.file_exists(state_path):
#		return load(state_path)
#
#	var file_sys_dir = get_editor_interface().get_resource_filesystem().get_filesystem_path(base_state_script.resource_path.get_base_dir())
#	var index = file_sys_dir.find_file_index(base_state_script.resource_path.get_file())
#	var cname = file_sys_dir.get_file_script_class_name(index)
#	if cname == "":
#		push_warning("base_state 没有设置 class_name，脚本默认继承为 \"base_state.gd\" ")
#		# 没有设置 class_name，设置为脚本路径名
#		cname = '"%s"' % base_state_script.resource_path.get_file()
#
#	# 生成脚本
#	var new_script = GDScript.new()
#	new_script.source_code = """## {comment}
#extends {cname}
#
#
##(override)
#func _enter_state(data = {}):
#	pass
#
#
##(override)
#func _exit_state():
#	pass
#
#""".format({
#		"cname": cname,
#		"comment": state_path.get_file().get_basename(),
#	})
#	new_script.resource_path = state_path
#	ResourceSaver.save(new_script, state_path)
#	print(">>> 生成新的 state 文件：", state_path)
#
#	get_editor_interface().get_resource_filesystem().scan_sources()
#
#	return new_script
#
#
#func add_state():
#	var state_name = state_line_text.text.strip_edges()
#	if state_name == "":
#		printerr('没有设置状态名！')
#		return
#	# 获取 base_state.gd 脚本路径
#	var base_state_script_path = get_base_state_script_path()
#	if not FileAccess.file_exists(base_state_script_path):
#		printerr("没有 ", base_state_script_path, " 脚本")
#		return
#
#	var scene_root = get_editor_interface().get_edited_scene_root() as Node
#	var base_state = load(base_state_script_path) as GDScript
#	# 加载脚本，没有则自动创建
#	var state_path = base_state_script_path.get_base_dir().path_join(state_name) + ".gd"
#	state_path = state_path.simplify_path()
#	var state_script = get_state_script(base_state, state_path)
#	if state_script == null:
#		printerr("没有 ", state_path, " 脚本")
#		return
#	# 创建新节点
#	var new_node = Node.new()
#	new_node.set_script(state_script)
#	if new_node:
#		var filename = base_state.resource_path.get_basename().get_file()
#		new_node.name = state_name
#		# 添加到场景中
#		var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
#		if selected_nodes.size() > 0:
#			# 添加到选中的节点上
#			selected_nodes[0].add_child(new_node, true)
#		else:
#			# 添加到当前场景根节点上
#			scene_root.add_child(new_node, true)
#		new_node.owner = scene_root
#		get_editor_interface().edit_node(new_node)
#		get_editor_interface().edit_script(state_script)
#		state_line_text.text = ""
#
#	else:
#			printerr("不是 FStateBase 或其子类型，不能自动添加这个节点")
#
#
### 扩展 StateNode 脚本
#func extend_script():
#	var base_state_script_path = get_base_state_script_path()
#	if not FileAccess.file_exists(base_state_script_path):
#		printerr("没有 ", base_state_script_path, " 文件")
#		printerr("请在这个场景目录下创建 state_machine 文件夹，并创建 base_state.gd 文件名的这个场景的 FState 基类")
#		return
#	var base_state_script = load(base_state_script_path)
#	var nodes = get_editor_interface().get_selection().get_selected_nodes()
#	if nodes.size() == 1:
#		var state = nodes[0]
#		if state is FStateBase:
#			var state_name = state_line_text.text.simplify_path()
#			if state_name == "":
#				# state_line_text 没有内容则默认加载脚本为节点名的脚本
#				state_name = str(state.name).capitalize().to_lower().replace(" ", "_")
#			var state_path = base_state_script_path.get_base_dir().path_join(state_name + ".gd")
#			var state_script = get_state_script(base_state_script, state_path)
#			state.set_script(state_script)
#			get_editor_interface().edit_script(state_script)
#
#		else:
#			printerr("选中的不是 FState 类型的节点")
#	else:
#		if nodes.size() == 0:
#			printerr("没有选中节点")
#		else:
#			printerr("选中了多个节点")
#
#

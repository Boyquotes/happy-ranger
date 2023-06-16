#============================================================
#    Bottom Panel
#============================================================
# - datetime: 2022-09-30 21:48:58
#============================================================
@tool
extends Control


##  点击重新加载按钮，如果是这个场景被修改了，则由于 Godot 的原因，这个不会生效了
signal reloaded


const ItemScene = preload("item/item.tscn")

const ItemMenu = preload("item_menu.gd")
const BottomPanel_Item = preload("item/item.gd")


var _init_node = FuncUtil.inject_by_unique(self, "node_")

var editor_interface : EditorInterface

var node_tree : Tree
var node_item_container : HFlowContainer
var node_reload_button : Button
var node_location_button : Button
var node_item_menu : ItemMenu
var node_save_data_timer : Timer
var node_sort_button: Button

var item_type_list := ["All"]

### 保存数据存储到的文件路径
#var data_file_path := get_script().resource_path.get_base_dir().path_join("data.gdata") as String

## 路径对应的Item
var path_to_item_map := {}
## 展示的类型
var show_type : String = "All"
## 当前选中的 Item
var selected_item : BottomPanel_Item  :
	set(v):
		selected_item = v
		var disable = (selected_item == null)
		node_item_menu.set_item_disabled_by_name( node_item_menu.menu_data.edit, disable )
		node_item_menu.set_item_disabled_by_name( node_item_menu.menu_data.open_explorer, disable )
		node_item_menu.set_item_disabled_by_name( node_item_menu.menu_data.remove, disable )
		
		if (selected_item 
			and (selected_item.resource == null or not selected_item.is_file())
		):
			node_item_menu.set_item_disabled_by_name( node_item_menu.menu_data.edit, true)

var _cache_data = CollectionPanelDataFile.instance(CollectionPanelUtils.CACHE_PATH)



#============================================================
#  SetGet
#============================================================
func get_editor_interface() -> EditorInterface:
	return editor_interface

func get_path_info(path: String) -> BottomPanel_Item:
	return path_to_item_map.get(path) as BottomPanel_Item

func get_select_item() -> BottomPanel_Item:
	return selected_item

func get_all_items() -> Array:
	return path_to_item_map.values()


#============================================================
#  内置
#============================================================
func _ready():
	var count = 0
	while _cache_data == null and count < 10:
		await Engine.get_main_loop().create_timer(0.1).timeout
		count += 1
	
	init_data.call_deferred()

func _exit_tree():
	for key in path_to_item_map:
		path_to_item_map[key] = null
	save_data()


#============================================================
#  自定义
#============================================================
func init_data():
	editor_interface = EditorUtil.get_editor_interface()
	
	while EditorUtil.get_filesystem_path("res://") == null:
		await get_tree().create_timer(0.1).timeout
	while node_sort_button == null:
		await get_tree().process_frame
	
	# 添加类别
	node_tree.clear_items()
	node_tree.add_type("All")
	
	# 加载初始化数据
	var files = _cache_data.get_value("file_list", path_to_item_map) as Dictionary
	for file in files:
		if ResourceLoader.exists(file) or DirAccess.dir_exists_absolute(file):
			add_item(file, false)
	_cache_data.replace.call_deferred("file_list", path_to_item_map)
	
	# 重新加载按钮
	node_reload_button.icon = EditorUtil.get_editor_theme_icon("Reload")
	node_reload_button.pressed.connect(func(): self.reloaded.emit() )
	
	# 文件定位按钮
	node_location_button.icon = EditorUtil.get_editor_theme_icon("TransitionSync")
	node_location_button.pressed.connect(func():
		# 判断当前所在编辑的视图
		var type = EditorUtil.get_main_screen_editor_name()
		if type == "Script":
			var current_script_path = get_editor_interface().get_script_editor().get_current_script().resource_path
			EditorUtil.navigate_to_path(current_script_path)
		elif type in ["2D", "3D"]:
			var root = get_editor_interface().get_edited_scene_root()
			if root:
				EditorUtil.navigate_to_path(root.scene_file_path)
			else:
				printerr("没有正在编辑的场景，定位失败")
		else:
			print("当前在其他视图中，无法定位当前文件")
	)
	
	# 排序按钮
	node_sort_button.icon = EditorUtil.get_editor_theme_icon("Sort")
	node_sort_button.button_pressed = true
	node_sort_button.toggled.connect(func(button_pressed: bool):
		for child in node_item_container.get_children():
			node_item_container.remove_child(child)
		
		if button_pressed:
			# 重新排序
			NodeUtil.add_node_by_list(node_item_container, func():
				var list = path_to_item_map.values().filter( func(node): 
					return node and node.visible 
				)
				list.sort_custom( func(a: Control, b: Control): 
					return a.filename.to_lower() < b.filename.to_lower() 
				)
				
				return list
			)
			
		else:
			
			# 还原顺序
			NodeUtil.add_node_by_list(node_item_container, func(): 
				return path_to_item_map.values()
			)
		
	)
	
	await get_tree().process_frame
	await get_tree().process_frame
	( func(): 
		node_sort_button.toggled.emit(true) 
		for item in path_to_item_map.values():
			add_item_type(item.type)
		
	).call_deferred()
	
	EditorUtil.get_base_control().theme_changed.connect(func():
		for item in get_all_items():
			item.reload_info()
	)


## 保存数据
func save_data():
	_cache_data.save()


## 添加 Item。[code]path[/code] 为添加的路径，[code]auto_save[/code] 是否自动保存数据
func add_item(path: String, auto_save: bool = true):
	if (FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path)):
		if not path_to_item_map.has(path):
			# 添加新的节点
			var item = ItemScene.instantiate() as BottomPanel_Item
			add_item_node(item)
			item.set_path(path)
			
			# 根据添加的节点的信息设置
			path_to_item_map[item.path] = item
			add_item_type(item.type)
			if node_sort_button.button_pressed:
				var list = path_to_item_map.values()
				list.sort_custom( func(a: BottomPanel_Item, b: BottomPanel_Item): 
					return a.filename.to_lower() < b.filename.to_lower() 
				)
				var index = list.find(item)
				node_item_container.move_child(item, index + 1 )
			
			# 添加后等待几秒间隔进行保存，以防止一次添加多个时保存次数过多
			if auto_save:
				node_save_data_timer.stop()
				node_save_data_timer.start()
			
		else:
			printerr("已添加这个文件：", path)
	else:
		printerr("没有这个文件：file = ", path)


## 添加 Item 节点
func add_item_node(item: BottomPanel_Item):
	node_item_container.add_child(item)
	# 连接信号
	item.double_clicked.connect(func():
		# 双加编辑文件
		if item.is_file() and item.resource != null:
			# 编辑资源
			if item.resource is PackedScene:
				get_editor_interface().open_scene_from_path( item.path )
			else:
				get_editor_interface().edit_resource( item.resource )
		# 定位到文件位置
		get_editor_interface().get_file_system_dock().navigate_to_path(item.path)
	)
	item.selected.connect(func(): self.selected_item = item )
	item.deselected.connect(func(): 
		await get_tree().process_frame
		self.selected_item = null 
	)
	# 右键点击
	item.right_clicked.connect(func():
		var p = Rect2(get_global_mouse_position(), self.node_item_menu.size)
		var last_selected_item = self.selected_item
		self.node_item_menu.popup(p)
		self.selected_item = item
		await self.node_item_menu.visibility_changed
		self.selected_item = item
	)
	update_item_visible(item)


## 添加这个项的类别
func add_item_type(type: String):
	if not item_type_list.has(type) and type != "":
		item_type_list.append(type)
		node_tree.add_type(type)


## 移出这个项
func remove_item(path:String):
	if path_to_item_map.has(path):
		var item = get_path_info(path) as BottomPanel_Item
		item.queue_free()
		path_to_item_map.erase(path)
		node_save_data_timer.stop()
		node_save_data_timer.start()
		print("已移除：", path)
	else:
		printerr("没有这个路径：", path)


## 更新这个 Item 的可见性
func update_item_visible(item: BottomPanel_Item):
	if show_type != "All":
		item.visible = (item.type == show_type)
	else:
		item.visible = true


#============================================================
#  连接信号
#============================================================
func _on_tree_selected_item(tree_item: TreeItem, data: Dictionary):
	show_type = ""
	if data.has("type"):
		var item : BottomPanel_Item
		show_type = data["type"] as String
		if show_type == "All":
			# 显示全部
			for path in path_to_item_map:
				item = get_path_info(path) as BottomPanel_Item
				item.visible = true
		else:
			# 展示要显示的类型
			for path in path_to_item_map:
				item = get_path_info(path) as BottomPanel_Item
				update_item_visible(item)


func _on_item_menu_clicked_item(id:int, item_name:String):
	if get_select_item() == null:
		print('没有选中 Item')
		return 
	var node_item_menu = get_select_item()
	var path := get_select_item().path as String
	match item_name:
		"edit":
			var resource = get_select_item().resource
			# 编辑这个资源
			if resource:
				get_editor_interface().edit_resource(resource)
			else:
				printerr('这个 Item 没有资源')
		
		"open explorer":
			# 打开文件夹位置
			if get_select_item().is_file():
				path = path.get_base_dir()
			path = ProjectSettings.globalize_path(path)
			OS.shell_open(path)
		
		"remove":
			# 移除掉这个路径
			remove_item(path)
		
		"play scene":
			editor_interface.play_custom_scene(path)
			
		
#	print("点击菜单：", item_name)


func _on_item_menu_popup_hide():
	self.selected_item = null



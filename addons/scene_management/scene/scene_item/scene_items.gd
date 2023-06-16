#============================================================
#    Scene Items
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-17 11:40:48
# - version: 4.0
#============================================================
@tool
class_name SceneManagementSceneItems
extends HFlowContainer


const SceneManagementItem = preload("scene_item.gd")


signal newly_added_item(path: String, item)
signal removed_item(path: String)
signal newly_group(group: String)

signal left_click(path: String)
signal right_click(path: String)
signal double_click(path: String)


@export var item_scene : PackedScene


var _canvas_item_class : Array = ClassDB.get_inheriters_from_class("CanvasItem")
var _node_3d_class : Array = ClassDB.get_inheriters_from_class("Node3D")

# 路径对应其配置数据
var _path_to_data_map : Dictionary = {}
# 是否可以进行处理选中操作的内容，防止遍历处理时处理多个
var _selected_handle : bool = true


class SceneItemData:
	var node : SceneManagementItem
	var path: String = ""
	var group : Array = []


#============================================================
#  SetGet
#============================================================
## 字典数据转为类
static func to_class_data(data: Dictionary) -> SceneItemData:
	return JsonUtil.dict_to_object(data, SceneItemData)

func get_item_count() -> int:
	return _path_to_data_map.size()

func get_path_list() -> Array:
	return _path_to_data_map.keys()

func get_all_data() -> Array:
	return _path_to_data_map.values()

func get_data(path: String) -> Dictionary:
	return DataUtil.get_value_or_set(_path_to_data_map, path, func(): return {})

func get_item_node(path: String) -> SceneManagementItem:
	return get_data(path).get("node")

func get_all_item_node() -> Array[SceneManagementItem]:
	var list : Array[SceneManagementItem] = []
	for path in _path_to_data_map:
		list.append(_path_to_data_map[path]['node'])
	return list

## 获取这个组中的所有数据
func get_group_data(group: String) -> Array[Dictionary]:
	var list : Array[Dictionary] = []
	for data in get_all_data():
		if data["group"].has(group):
			list.append(data)
	return list


## 获取这个路径的标签组
func get_group_by_path(path: String) -> Array:
	if _path_to_data_map.has(path):
		return _path_to_data_map[path]['group']
	return []


## 获取所有选中的节点
func get_selected_item_list() -> Array[SceneManagementItem]:
	return get_all_item_node() \
		.filter(func(item: SceneManagementItem): return item.is_selected() and item.visible)

## 存在组中的 Item
func has_group_item(group: String) -> bool:
	for data in get_all_data():
		if data["group"].has(group):
			return true
	return false


#============================================================
#  内置
#============================================================
func _ready():
	# 读取数据
	const KEY = "SceneItemPathList"
	var items_list = SceneManagement.get_data(KEY, {})
	for path in items_list.keys():
		var data = items_list[path]
		add_item(path, data)
		# 一次性加载完有点卡，所以使用这种式加载
		await Engine.get_main_loop().process_frame
	
	# 重设为当前引用的数据
	SceneManagement.reset_data(KEY, _path_to_data_map)


func _can_drop_data(at_position, data):
	return data is Dictionary \
		and data.has('type') \
		and (data['type'] == 'files' or data['type'] == "files_and_dirs")


func _drop_data(at_position, data):
	if data['type'] == "files":
		for file in data['files']:
			if FileAccess.file_exists(file):
				add_item(file)
	
	elif data['type'] == "files_and_dirs":
		for file in data['files']:
			if FileAccess.file_exists(file):
				add_item(file)
			elif DirAccess.dir_exists_absolute(file):
				for i in FileUtil.scan_file(file):
					add_item(i)


#============================================================
#  自定义
#============================================================
##  添加场景，并添加附加数据
##[br]
##[br][code]path[/code]  场景路径
##[br][code]data[/code]  附加数据
func add_item(path: String, data: Dictionary = {}):
	if _path_to_data_map.has(path):
		return
	if not path.get_extension() in ['tscn', "scn"]:
		return
	
	# 添加节点
	var item = item_scene.instantiate() as SceneManagementItem
	add_child.call_deferred(item)
	item.set_file_path(path)
	
	item.left_clicked.connect(func(): self.left_click.emit(path))
	item.right_clicked.connect(func(): 
		_selected_handle = false
		if not (Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_SHIFT)) and not item.is_selected():
			for selected_item in get_selected_item_list():
				selected_item.set_selected(false)
			item.set_selected(true)
		else:
			item.set_selected(true)
		self.right_click.emit(path)
		_selected_handle = true
	)
	item.double_clicked.connect(func():
		EditorUtil.get_editor_interface().open_scene_from_path(path)
		EditorUtil.navigate_to_path(path)
		
		# 切换到对应节点类型的视图
		var c_name = item.get_root_node_type()
		# 下面代码先设置到当前插件视图，是因为有时候看着是在其他视图中，
		# 但内部数据没有更新还是在 2D/3D 视图，点击的话就没反应
		# 所以要先切换一下防止这种问题
		if _canvas_item_class.has(c_name):
			EditorUtil.set_main_screen_editor(SceneManagement.PLUGIN_MAIN_NAME)
			await Engine.get_main_loop().process_frame
			EditorUtil.set_main_screen_editor("2D")
			
		elif _node_3d_class.has(c_name):
			EditorUtil.set_main_screen_editor(SceneManagement.PLUGIN_MAIN_NAME)
			await Engine.get_main_loop().process_frame
			EditorUtil.set_main_screen_editor("3D")
		
		item.release_focus()
		item.hide_border()
		self.double_click.emit(path)
	)
	item.select_changed.connect(func(state):
		if _selected_handle:
			_selected_handle = false
			
			if state:
				# 没有按下 Ctrl 或 Shift 时，其他选中的部取消
				if not (Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_SHIFT)):
					for selected_item in get_selected_item_list():
						selected_item.set_selected(false)
					item.set_selected(true)
				
				else:
					if Input.is_key_pressed(KEY_SHIFT):
						var list = get_selected_item_list()
						if list.size() > 1:
							var index_list = list.map(func(item): return item.get_index())
							var from : int = index_list.min()
							var to : int = index_list.max()
							for i in range(from, to + 1):
								var child = get_child(i) as SceneManagementItem
								if child.visible:
									child.set_selected(true)
				
			else:
				
				if not (Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_SHIFT)):
					var list = get_selected_item_list()
					if not list.is_empty():
						# 如果中了多个，则这次只选中这一个，其他取消选中
						for i in list:
							i.set_selected(false)
						item.set_selected(true)
			
			await Engine.get_main_loop().process_frame
			_selected_handle = true
			
	)
	
	# 这个路径其他详细数据
	data["node"] = item
	data["path"] = path
	if not data.has("group"):
		data['group'] = []
	_path_to_data_map[path] = data
	
	self.newly_added_item.emit(path, item)


func add_group(path: String, group: String):
	if _path_to_data_map.has(path):
		var data = get_data(path)
		if not data['group'].has(group):
			data['group'].append(group)


func remove_group(path: String, group: String):
	if _path_to_data_map.has(path):
		get_data(path)['group'].erase(group)


func remove_item(path: String):
	if not _path_to_data_map.has(path):
		return
	
	self.removed_item.emit(path)
	
	# 移除节点
	var item : Node = _path_to_data_map[path]['node']
	item.queue_free()
	
	# 移除数据
	_path_to_data_map.erase(path)
	
	print("[ SceneManagement ] 移除：", path)


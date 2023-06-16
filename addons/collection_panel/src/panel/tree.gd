#============================================================
#    Tree
#============================================================
# - datetime: 2022-09-30 22:49:18
#============================================================
@tool
extends Tree

## 发出选中的 Item 的数据
signal selected_item(item: TreeItem, data: Dictionary)
## 拖拽放下文件
signal drop_file(path:String)


var root := create_item() as TreeItem
var type_item_map := {}


enum MetaColumn{
	TYPE
}


#============================================================
#  内置
#============================================================
func _ready():
	hide_root = true
	item_selected.connect(func():
		var data = {}
		var item := get_selected()
		if item:
			data['type'] = item.get_metadata(MetaColumn.TYPE)
		selected_item.emit(item, data)
	)

func _can_drop_data(at_position, data):
	return data is Dictionary

func _drop_data(at_position, data):
	print("file_tree: ", data)
	if data is Dictionary and data.has("files"):
		var files = data['files'] as Array
		for file in files:
			drop_file.emit(file)


#============================================================
#  自定义
#============================================================
func clear_items():
	for i in root.get_children():
		root.remove_child(i)

func add_type(type:String):
	var item := root.create_child()
	item.set_text(0, type)
	item.set_metadata(MetaColumn.TYPE, type)
	type_item_map[type] = item


func add_item_to_type(type:String, text:String):
	if type_item_map.has(type):
		var type_item := type_item_map[type] as TreeItem
		var item = type_item.create_child()
		item.set_text(0, text)



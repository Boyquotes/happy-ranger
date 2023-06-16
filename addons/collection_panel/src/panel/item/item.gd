#============================================================
#    Item
#============================================================
# - datetime: 2022-09-30 21:49:52
#============================================================
@tool
extends MarginContainer


signal clicked
signal double_clicked
signal selected
signal deselected
signal right_clicked
signal hovered


@onready var node_label := %label as Label
@onready var node_texture_rect := %texture_rect as TextureRect
@onready var node_background : Panel = %background

var path: String : set = set_path

var filename: String
var type: String
var file_sys_dir : EditorFileSystemDirectory
var resource : Resource = null


#============================================================
#  SetGet
#============================================================
func set_path(v: String):
	path = v
	if node_label == null:
		await self.ready
	
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	
	self.tooltip_text = path
	
	var file_sys_dir : EditorFileSystemDirectory
	if FileAccess.file_exists(path):
		type = "File"
		filename = path.get_file()
		file_sys_dir = EditorUtil.get_filesystem_path(path.get_base_dir())
		var idx = file_sys_dir.find_file_index(filename)
		type = file_sys_dir.get_file_type(idx)
		resource = load(path)
		if resource is Script:
			type = "Script"
	else:
		file_sys_dir = EditorUtil.get_filesystem_path(path)
		type = "Folder"
		filename = path.substr(0, len(path)-1).get_file()
	
	Log.info("已加载：%s" % path)
	node_label.text = filename
	# 加载图标
	var texture = EditorUtil.get_editor_theme_icon(type)
	if texture == null:
		texture = load("res://icon.svg")
	node_texture_rect.texture = texture

func is_file():
	return type != "Folder"

func reload_info():
	set_path(path)


#============================================================
#  内置
#============================================================
func _ready():
	mouse_entered.connect( self.node_background.show )
	mouse_exited.connect( self.node_background.hide )
	focus_entered.connect(func(): self.selected.emit() )
	focus_exited.connect(func(): self.deselected.emit() )


func _gui_input(event):
	if InputUtil.is_double_click(event):
		double_clicked.emit()
	elif InputUtil.is_click_right(event):
		right_clicked.emit()


func _get_drag_data(at_position):
	var label = self.duplicate(0)
	set_drag_preview(label)
	return {
		"type": "files" if FileAccess.file_exists(path) else "files_and_dirs",
		"files": [path],
	}
	



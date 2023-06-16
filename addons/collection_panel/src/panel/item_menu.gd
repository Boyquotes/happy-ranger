#============================================================
#    Item Menu
#============================================================
# - datetime: 2022-10-01 11:13:00
#============================================================
@tool
extends PopupMenu


signal clicked_item(id, item_name)


var menu_data := {
	edit = "edit",
	play_scene = "play scene",
	sep_01 = "---",
	open_explorer = "open explorer",
	sep_02 = "---",
	remove = "remove",
}


func _ready():
	clear()
	for key in menu_data:
		if menu_data[key] == "":
			menu_data[key] = key
		if menu_data[key] != "---":
			add_item(menu_data[key])
		else:
			add_separator()
	
	id_pressed.connect(func(id): 
		self.clicked_item.emit( id, menu_data.values()[id] ) 
	)


func set_item_disabled_by_name(menu_namae:String, disable:bool):
	var id : int = menu_data.values().find(menu_namae)
	if id > -1:
		set_item_disabled(id, disable)


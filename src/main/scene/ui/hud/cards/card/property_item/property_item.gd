#============================================================
#    Property Item
#============================================================
# - datetime: 2023-02-26 23:35:27
#============================================================
@tool
extends Control


@export
var texture : Texture2D:
	set(v):
		texture = v
		_update_prop()
@export
var text : String :
	set(v):
		text = v
		_update_prop()


@onready 
var image: TextureRect = %image
@onready 
var value: Label = %value


func _update_prop():
	if image == null: await ready
	image.texture = texture
	value.text = text


func _ready() -> void:
	_update_prop()


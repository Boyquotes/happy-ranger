#============================================================
#    Player Message
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-08 00:04:03
# - version: 4.x
#============================================================
extends MarginContainer


const MessageItemScene = preload("message_item.tscn")


@onready var item_container = %item_container


func _ready():
	for i in 10:
		add_item(str(i))
		await get_tree().create_timer(0.2)
		


func add_item(text: String):
	var item = MessageItemScene.instantiate()
#	item.text = text
	item_container.add_child(item)
	item.execute(0.6)
	
	item.custom_minimum_size = Vector2(100, 100)


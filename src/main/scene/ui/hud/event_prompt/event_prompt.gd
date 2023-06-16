#============================================================
#    Event Prompt
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-14 16:07:14
# - version: 4.x
#============================================================
## 事件消息提醒
@tool
class_name EventPrompt
extends Control


@export var image : Texture2D:
	set(v):
		image = v
		FuncUtil.sync_property(func(): texture_rect.texture = image)
@export_multiline var text : String = "":
	set(v):
		text = v
		FuncUtil.sync_property(func(): label.text = text)


var __init_node__ = FuncUtil.inject_by_unique(self)
var texture_rect : TextureRect
var label : Label
var content : MarginContainer


func _ready():
	if not Engine.is_editor_hint():
		get_child(0).visible = false
		GameEvent.TopMessage.listen(self.popup)
	


##  弹出窗口
##[br]
##[br][code]texture[/code]  显示图像
##[br][code]text[/code]  显示内容
##[br][code]vanishing[/code]  消失时间
##[br][code]return[/code]  返回弹窗对象
static func popup(texture: Texture2D, text: String, vanishing: float = 3.0) -> EventPrompt:
	if not HUD.has_hud():
		printerr("游戏中没有HUD对象！")
		return null
	
	# 获取当前类的场景
	const KEY = "EventPrompt_popup_path"
	var scene = DataUtil.singleton(KEY, func():
		var path = ScriptUtil.get_object_script_path(EventPrompt).get_basename()
		return load(path + ".tscn") as PackedScene
	) as PackedScene
	
	# 创建并添加到场景中
	var event := scene.instantiate() as EventPrompt
	HUD.get_instance().add_child(event)
	event.label.text = text
	event.texture_rect.texture = texture
	
	# 播放动画
	var duration = 0.5
	var view_size = NodeUtil.get_tree().root.get_visible_rect().size
	event.position.x = (view_size.x - event.size.x) / 2.0
	event.position.y = -event.size.y
	var curve = preload("event_prompt_curve.tres")
	FuncUtil.execute_curve_tween(curve, event, "position:y", 16.0, duration)
	
	event.content.modulate.a = 0
	event.scale.x = 0.1
	NodeUtil.create_once_timer(0.2, 
		func():
			NodeUtil.create_tween() \
				.tween_property(event, "scale:x", 1, 0.25) \
				.set_trans(Tween.TRANS_BOUNCE) \
				.set_ease(Tween.EASE_OUT)
			
			NodeUtil.create_tween() \
				.tween_property(event.content, "modulate:a", 1, 0.1)
		
	)
	
	# 消失
	var timer = NodeUtil.create_once_timer(duration + vanishing, func():
		FuncUtil.execute_curve_tween(curve, event, "position:y", 16.0, duration, true, -event.size.y)
		NodeUtil.create_once_timer(duration, event.queue_free)
#		NodeUtil.create_tween() \
#			.tween_property(event, "modulate:a", 0.0, 0.45) \
#			.set_ease(Tween.EASE_OUT) \
#			.finished.connect(
#				func():
#					event.queue_free()
#		)
	)
	
	# 点击立即
	event.gui_input.connect(func(input):
		if (InputUtil.is_click_left(input)
			and is_instance_valid(timer)
			and timer.time_left > 0
		):
			event.mouse_filter = Control.MOUSE_FILTER_IGNORE
			timer.timeout.emit()
			timer.queue_free()
		
	)
	
	return event


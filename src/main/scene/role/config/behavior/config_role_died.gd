#============================================================
#    Died
#============================================================
# - datetime: 2023-03-02 22:05:11
# - version: 4.x
#============================================================
## 死亡
class_name ConfigRoleDied
extends ConfigBehavior


## 删除这个对象
@export var free_role : bool = true
## 死亡时播放的动画
@export var died_animation : String = "death"
## 死亡角色存在到场景的时间
@export var died_time : float = -1.0
## 关闭碰撞
@export_node_path("CollisionShape2D", "CollisionPolygon2D")
var collision : NodePath
## 死亡时创建的场景节点
@export var create_scene : PackedScene
## 延迟创建时间
@export var delay_create_time : float = 0.0
## 自动缩放
@export var auto_scale : bool = true


#(override)
func _set_enabled(value):
	enabled = value


#(override)
func _actor_ready():
	super._actor_ready()
	
	get_listener().listen(role.died, func(data):
		if not enabled:
			return
		
		# 播放动画
		if died_animation:
			role.play.call_deferred(died_animation)
		
		# 创建节点
		if create_scene:
			var s = create_scene.instantiate()
			if s is Node2D:
				s.global_position = role.global_position
				if auto_scale:
					var scale = CanvasUtil.get_canvas_scale_diff(role.anim_canvas.get_target(), s)
					if scale != Vector2(0,0):
						s.scale = scale
			if delay_create_time > 0:
				get_tree().create_timer(delay_create_time).timeout.connect(func():
					NodeUtil.add_node(s)
				)
			else:
				NodeUtil.add_node(s)
		
		# 关闭碰撞
		if not collision.is_empty():
			var node = get_node_or_null(collision)
			if node:
				node.set_deferred(&"disabled", true)
				Log.error(["角色已死亡，关闭碰撞"])
		
		# 移除
		if died_time < 0:
			if role.has_animation(died_animation):
				var time = CanvasUtil.get_animation_sprite_time(role.anim_canvas.get_target(), died_animation)
				await get_tree().create_timer(time).timeout
		elif died_time > 0:
			await get_tree().create_timer(died_time).timeout
		
		if free_role and is_instance_valid(role):
			await Engine.get_main_loop().process_frame
			role.queue_free()
		
	)


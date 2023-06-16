#============================================================
#    Goods
#============================================================
# - datetime: 2023-01-01 17:21:13
#============================================================
@tool
class_name Goods
extends CharacterBody2D


@export var texture : Texture2D : set=set_texture
@export var gravity_speed : float = 250
@export var gravity_max : float = 200
@export var data : Dictionary


@onready var image: TextureRect = %image
@onready var collision_shape: CollisionShape2D = $collision_shape
@onready var anim_player: AnimationPlayer = $default_item_effect/anim_player

@onready var _last_pos : Vector2 = global_position

var _velocity : Vector2
var _speed


#============================================================
#  SetGet
#============================================================
func set_data(v: Dictionary):
	data = v

func get_data():
	return data

func set_texture(v: Texture2D):
	texture = v
	if image == null: await ready
	image.texture = v


#============================================================
#  内置
#============================================================
func _enter_tree() -> void:
	set_physics_process( not Engine.is_editor_hint() )


func _ready() -> void:
	set_physics_process( not Engine.is_editor_hint() )
	if not Engine.is_editor_hint():
		anim_player.speed_scale = randf_range(0.8, 1.2)


func _physics_process(delta: float) -> void:
	_velocity.y += gravity_speed * delta
	_velocity.y = min(_velocity.y, gravity_max)
	velocity = _velocity
	if move_and_slide():
		var normal = get_last_slide_collision().get_normal()
		_velocity = (global_position - _last_pos) / delta
		# 反弹并造成速度衰减
		_velocity = _velocity.bounce(normal) * 0.7
	
	_last_pos = global_position
	
	if is_on_floor_only():
		self.collision_layer |= Const.PhysicsLayer.ITEM
		



#============================================================
#  自定义
#============================================================
## 通过数据创建物品
static func create(data: Dictionary = {}) -> Goods:
	var scene = DataUtil.singleton("ItemNode_create", func():
		return ScriptUtil.get_script_scene(Goods)
#		var path = ScriptUtil.get_object_script_path(Goods).get_basename() + ".tscn"
#		return load(path)
	) as PackedScene
	var item = scene.instantiate() as Goods
	if data:
		item.set_data(data)
		if data.has(Const.TEXTURE) and data[Const.TEXTURE] != null:
			item.set_texture(data[Const.TEXTURE])
	return item


##  施加作用力
##[br]
##[br][code]vector[/code]  
##[br][code]attenuation[/code]  
func apply_force(vector: Vector2, attenuation: float):
	_velocity = vector
	attenuation *= sign(velocity.x)
	
	var timer = DataUtil.get_ref_data(null)
	timer.value = FuncUtil.execute_fragment_process(INF, func():
		_velocity.x -= attenuation * get_physics_process_delta_time()
		if abs(_velocity.x) <= 5:
			timer.queue_free()
	)
	
#
#	var vel = DataUtil.get_ref_data(vector)
#	var timer = DataUtil.get_ref_data(null)
#	timer.value = FuncUtil.execute_fragment_process(INF, func():
#		var length = vel.value.length() - attenuation * get_physics_process_delta_time()
#		if length <= 5:
#			timer.queue_free()
#			return
#
#		if is_on_floor_only():
#			length = max(0, length - length * 0.6 * 6 * get_physics_process_delta_time())
#
#		vel.value = vel.value.limit_length(length)
#		self.velocity = vel.value
#		if self.move_and_slide():
#			vel.value *= 0.6
#
##		if self.move_and_slide():
##			# 反弹
##			var normal = get_last_slide_collision().get_normal()
##			vel.value = vel.value.bounce(normal) * 0.6
#
#	, 0, self)


## 捡取物品
func take_item(source: Node2D):
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	
	# 漂浮到目标身上效果
	var dist = MathUtil.N.distance_to(self, source)
	var time = dist / 64.0
	var to = source.global_position
	create_tween().tween_property(image, "global_position", to, time)
	create_tween().tween_property(image, "modulate:a", 0, time)
	get_tree().create_timer(time).timeout.connect(self.queue_free)


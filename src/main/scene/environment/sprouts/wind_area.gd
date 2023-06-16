#============================================================
#    Wind Area
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-12 23:08:38
# - version: 4.0
#============================================================
## 风吹动区域
##
## 添加到一个 [CanvasItem] 类型的节点下面 
class_name WindArea
extends Area2D


const SHADER_CODE : String = """
shader_type canvas_item;
render_mode blend_mix;


// 控制最大吹动的强度
uniform vec2 wind = vec2(0, 0);
// 控制被吹动到左右的比值
uniform float offset : hint_range(-1., 1., 0.01) = 0.;


void vertex() {
	VERTEX.y += 1. - UV.y + wind.y;
	VERTEX.x += wind.x * offset * ((1. - UV.y) / VERTEX.y);
}

"""


## 是否可用
@export var enabled : bool = true
## 摇摆幅度。值越大，摇摆越剧烈
@export var amplitude : float = 5.0:
	set(v):
		amplitude = v
		if _target_material == null: await ready
		_target_material.set_shader_parameter("wind", Vector2(amplitude, 0))
## 摇摆次数。左右摇摆一个来回算一次
@export_range(1, 100, 1, "or_greater") 
var range_count : int = 3
## 摇摆持续时间
@export_range(0.01, 100, 0.001, "or_greater", "hide_slider") 
var duration : float = 2.0


var _ratio_cache := AngleRatioCache.new()
var _tween : Tween
var _target_material : ShaderMaterial = ShaderMaterial.new()



#============================================================
#  内置
#============================================================
func _ready():
	if get_parent() is CanvasItem:
		get_parent().material = _target_material
	
	const KEY = &"WindArea_shader"
	var shader : Shader
	if Engine.has_meta(KEY):
		shader = Engine.get_meta(KEY)
	else:
		shader = Shader.new()
		shader.code = SHADER_CODE
		Engine.set_meta(KEY, shader)
	
	_target_material.shader = shader
	
	# 创建碰撞形状
	if "texture" in get_parent():
		CollisionUtil.create_rectangle_collision(get_parent().texture.get_size() * get_parent().scale, self)
	self.collision_layer = 0
	self.collision_mask = Const.PhysicsLayer.ROLE
	self.monitorable = false	# 自身不可被检测到，节省点资源
	
	var collision_shape : Node2D
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			collision_shape = child
			break
	
	# 进入区域后执行动作	
	area_entered.connect(func(area):
		if area is BodyArea:
			var dir = (collision_shape.global_position + Vector2(8, 16)) - area.global_position
			execute(dir.x)
	)


#============================================================
#  自定义
#============================================================
##  执行方法
##[br]
##[br][code]left_or_right[/code]  初始摇摆方向。先向左还是向右摇摆
func execute(left_or_right: float = 0.0):
	if not enabled:
		return
	
	Log.info([left_or_right])
	# 摇摆幅度
	_target_material.set_shader_parameter("wind", Vector2(amplitude, 0))
	
	#  默认先偏向左边，增加旋转 180 度旋转到右边
	var offset : float = 0.0
	if left_or_right > 0:
		offset = 180.0
	else:
		offset = 0
	
	if is_instance_valid(_tween):
		_tween.stop()
	_tween = create_tween()
	
	# 摇摆最大值
	var max_v : float = 360.0 * range_count
	_tween.chain().tween_method(func(v: float):
			var ratio = v / max_v
			_target_material.set_shader_parameter( "offset", _ratio_cache.get_value(v  + offset) * ratio )
			,
		max_v, 0, duration)


func stop():
	if is_instance_valid(_tween):
		_tween.stop()


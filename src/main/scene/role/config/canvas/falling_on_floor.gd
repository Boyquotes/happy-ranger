#============================================================
#    Falling On Floor
#============================================================
# - datetime: 2023-03-03 23:59:39
# - version: 4.x
#============================================================
## 落在地板上显示烟雾特效
class_name ConfigFallingOnFloor
extends ConfigCanvas


@export var effect : PackedScene
@export var offset_pos : Vector2 = Vector2(0,0)


var last_on_floor : bool = true
var random_count := RandomMinimumProbability.new(0.3)


func _ready():
	assert(effect != null, str(role) + "必须设置落在上的特效场景")
	set_physics_process( role.move_controller is PlatformController )


func _physics_process(delta):
	if role.is_on_floor_only():
		if not last_on_floor:
			if random_count.check():
				var ef = effect.instantiate()
				if ef is AnimatedSprite2D:
					ef.animation_finished.connect(ef.queue_free)
				var pos : Vector2 = role.global_position + offset_pos
				ef.global_position = pos
				NodeUtil.add_node(ef)
		
		last_on_floor = true
	else:
		last_on_floor = false


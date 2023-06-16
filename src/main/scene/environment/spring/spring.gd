#============================================================
#    Spring
#============================================================
# - datetime: 2023-01-02 22:57:13
#============================================================
## 弹簧
class_name Spring
extends EnvironmentArea


const HALF_PI = PI / 2.0


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var node_map = {}


#============================================================
#  内置
#============================================================
func _ready() -> void:
	self.collision_layer = 0
	self.collision_mask = Const.PhysicsLayer.ROLE
	self.body_entered.connect(func(body):
		if body is Role:
			# 是地面角色且正在降落中
			if body.is_ground() and body.is_falling():
				var angle = body.global_position.angle_to_point(self.global_position + Vector2(8, 16))
				Log.info([ angle ])
				if MathUtil.is_in_range(angle, HALF_PI * 0.45, HALF_PI * 1.65):
					animated_sprite_2d.stop()
					animated_sprite_2d.frame = 0
					animated_sprite_2d.play("pop_up")
					
					body.jump(244, true, {
						Const.TYPE: "spring",
						Const.SOURCE: self,
					})
	)



func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("default")

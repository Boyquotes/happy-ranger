#============================================================
#    Config Role Property
#============================================================
# - datetime: 2023-03-01 22:09:59
# - version: 4.x
#============================================================
class_name ConfigRoleProperty
extends ConfigRole



@export
var health_max : float = 3
@export
var health : float =  3
@export
var move_speed : float = 50
@export
var custom : Dictionary = {}


#(override)
func _actor_ready():
	super._actor_ready()
	
	var data = JsonUtil.object_to_dict(self)
	role.init_property(custom)
	role.init_property(data)



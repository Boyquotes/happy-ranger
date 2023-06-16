#============================================================
#    Function Data Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-26 15:39:58
# - version: 4.0
#============================================================
class_name FunctionDataUtil


static func call_method_data(
	method: String,
	parameters: Array = [],
) -> Dictionary:
	return {
		"method": method,
		"parameters": parameters,
	}


static func control_property_data(
	property: String,
	value,
) -> Dictionary:
	return {
		"property": property,
		"value": value,
	}


static func creator_data(
	scene: PackedScene,
	create_position: Vector2,
	rotation: float,
) -> Dictionary:
	return {
		"scene": scene,
		"create_position": create_position,
		"rotation": rotation,
	}


static func missile_data(
	scene: PackedScene,
	create_position: Vector2,
	rotation: float,
	velocity: Vector2
) -> Dictionary:
	return {
		"scene": scene,
		"create_position": create_position,
		"velocity": velocity,
		"rotation": rotation,
	}


static func sprint_data(
	direction: Vector2,
	speed: float,
) -> Dictionary:
	return {
		"direction": direction,
		"speed": speed,
	}



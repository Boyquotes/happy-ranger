#============================================================
#    F Blackboard
#============================================================
# - datetime: 2022-09-13 13:39:00
#============================================================

class_name FBlackboard


signal property_changed(property, previous, current)


var __data : Dictionary = {}
var __previous_value


func set_property(property, value):
	__previous_value = __data.get(property)
	if __previous_value != value:
		__data[property] = value
		property_changed.emit(property, __previous_value, value)


func get_property(property, default=null):
	return __data.get(property, default)

func has_property(property) -> bool:
	return __data.has(property)

func add_property(property, value):
	set_property(property, get_property(property) + value )


func sub_property(property, value):
	set_property(property, get_property(property) - value )


func remove_property(property):
	__data.erase(property)



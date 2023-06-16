#============================================================
#    Sewer
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-13 17:23:47
# - version: 4.0
#============================================================
## 下水道
class_name Sewer
extends Node2D


enum WaterType {
	## 细水
	FIND_WATER,
	## 宽一些的水
	WIDE_WATER,
}

@export var target_tilemap : TileMap:
	set(v):
		target_tilemap = v
		if not self.is_inside_tree(): await ready
		update_by_tilemap(target_tilemap)
## 判断是否存在瓦片判断的层级
@export var tile_layer: int = 0
## 细水
@export var fine_water : Texture2D
## 地面上的细水
@export var fine_water_on_ground : Texture2D
## 宽一些的水
@export var wide_water : Texture2D
## 地面上的宽一些的水
@export var wide_water_on_ground : Texture2D
## 底部的水（左）
@export var bottom_water_left_16_y : Texture2D
## 底部的水（中）
@export var bottom_water_center_8_y : Texture2D
## 底部的水（右）
@export var bottom_water_right_16_y : Texture2D


func update_by_tilemap(tilemap: TileMap) -> void:
	# 当前点在 TileMap 上的坐标 
	var local = tilemap.to_local(self.global_position)
	var coordinate = tilemap.local_to_map(local)
	
	# 向下遍历空白位置，进行流水
	var rect = tilemap.get_used_rect()
	var last_water_type : WaterType = WaterType.FIND_WATER
	var last_coordinate : Vector2i = coordinate + Vector2i(0, 1)
	var current_coordinate : Vector2i = coordinate
	var a = 0.8
	var count : int = 0
	for y in range(coordinate.y, rect.end.y):
		current_coordinate.y = y
		var id = tilemap.get_cell_source_id(tile_layer, current_coordinate)
		if id != -1:
			var cell_length : int = current_coordinate.y - last_coordinate.y
			var m : NinePatchRect
			var n : NinePatchRect
			if last_water_type == WaterType.FIND_WATER:
				m = create_water(fine_water, last_coordinate.y, cell_length - 1, coordinate.y)
				n = create_water(fine_water_on_ground, current_coordinate.y - 1, 1, coordinate.y)
				last_water_type = WaterType.WIDE_WATER
			else:
				m = create_water(wide_water, last_coordinate.y, cell_length - 1, coordinate.y)
				n = create_water(wide_water_on_ground, current_coordinate.y - 1, 1, coordinate.y)
			m.modulate.a = a
			n.modulate.a = a
			
			count += 1
			if count == 3:
				break
			
			last_coordinate.y = y
			a *= 0.7
	
	# 底部溅出的水
	if tilemap.get_cell_source_id(tile_layer, current_coordinate + Vector2i.LEFT) != -1:
		create_water(bottom_water_left_16_y, current_coordinate.y-1, 2, coordinate.y, -1).modulate.a = a
	create_water(bottom_water_center_8_y, current_coordinate.y, 1, coordinate.y, 0).modulate.a = a
	if tilemap.get_cell_source_id(tile_layer, current_coordinate + Vector2i.RIGHT) != -1:
		create_water(bottom_water_right_16_y, current_coordinate.y-1, 2, coordinate.y, 1).modulate.a = a
	


func create_water(texture: Texture2D, pos_y_cell: int, cell_length: int, offset_y: int, offset_x: int = 0) -> NinePatchRect:
	var last_texture_node : NinePatchRect = NinePatchRect.new()
	last_texture_node.size = Vector2(16, 16)
	last_texture_node.size.y = cell_length * 16
	last_texture_node.texture = texture
	add_child(last_texture_node)
	last_texture_node.position.y = (pos_y_cell - offset_y) * 16
	last_texture_node.position.x += offset_x * 16
	return last_texture_node


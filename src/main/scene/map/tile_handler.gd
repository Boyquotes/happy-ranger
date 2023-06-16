#============================================================
#    Tile Handler
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-29 16:30:48
# - version: 4.0
#============================================================
## tilemap 处理
class_name TileHandler
extends Node


# 地图册坐标的瓦片对应的场景
var atlas_to_scene_map = {
	hash( [1, Vector2i(0, 3)] ): ScriptUtil.get_script_scene(Stairs),
	hash( [1, Vector2i(0, 8)] ): ScriptUtil.get_script_scene(Spring),
	hash( [1, Vector2i(1, 8)] ): ScriptUtil.get_script_scene(Spring),
	hash( [1, Vector2i(2, 8)] ): ScriptUtil.get_script_scene(Spring),
	
	hash( [3, Vector2i(5, 9)] ): ScriptUtil.get_script_scene(Sprouts),
	hash( [3, Vector2i(6, 9)] ): ScriptUtil.get_script_scene(Sprouts),
	hash( [3, Vector2i(7, 10)] ): ScriptUtil.get_script_scene(Skull),
	hash( [3, Vector2i(8, 10)] ): ScriptUtil.get_script_scene(Skull),
	hash( [3, Vector2i(3, 11)] ): ScriptUtil.get_script_scene(Tombstone),
	hash( [3, Vector2i(4, 11)] ): ScriptUtil.get_script_scene(Tombstone),
	hash( [3, Vector2i(5, 11)] ): ScriptUtil.get_script_scene(Tombstone),
	hash( [3, Vector2i(6, 11)] ): ScriptUtil.get_script_scene(Tombstone),
	hash( [3, Vector2i(10, 11)] ): ScriptUtil.get_script_scene(Rhizome),
	
	hash( [0, Vector2i(0, 8)] ): ScriptUtil.get_script_scene(Sewer),
	
	hash( [1, Vector2i(35, 26)] ): ScriptUtil.get_script_scene(Chest),
	
}

#var tilemap_to_passway : Dictionary = {}


#============================================================
#  SetGet
#============================================================
#func get_passway(tilemap: TileMap) -> Dictionary:
#	return tilemap_to_passway.get(tilemap, {})


#============================================================
#  自定义
#============================================================
func execute(tilemap: TileMap):
#	# 获取有可通行的路径的数据
#	var tilemap_data = TileMapUtil.find_passageway(tilemap)
#	tilemap_to_passway[tilemap] = {}
#	for direction in tilemap_data:
#		var list : Array[Vector2i] = DataUtil.to_type_array(TYPE_VECTOR2I, tilemap_data[direction])
#		if list.size() >= 2:
#			# 获取这个方向的连接的点
#			var conn_data_list = TileMapUtil.get_connected_cell(tilemap, list)
#			for conn_data in conn_data_list:
#				var from : Vector2i = conn_data['from']
#				var to : Vector2i = conn_data['to']
#				# 连接两个点
#				FuncUtil.for_vector2i(from, to, func(coordinate):
#					tilemap.set_cell(Const.TileCellLayer.BACKGROUND, coordinate, 1, Vector2(0, 0))
#				)
#
#				# 这个方向的连接
#				var conn_list = DataUtil.get_value_or_set(tilemap_to_passway[tilemap], direction, func(): return [])
#				conn_list.append(from)
#				conn_list.append(to)
	
	# 颜色调暗，使可操作的对象更突出
	tilemap.set_layer_modulate(Const.TileCellLayer.BASE, Color(1, 1, 1, 0.85))
	tilemap.set_layer_modulate(Const.TileCellLayer.DECORATION, Color(1, 1, 1, 0.85))
	tilemap.set_layer_modulate(Const.TileCellLayer.BACKGROUND, Color(1, 1, 1, 0.85))
	
	# 替换瓦片
	var tile_size : Vector2i = tilemap.tile_set.tile_size
	var source_id : int
	var atlas_coords : Vector2i
	var id : int 
	var scene : PackedScene
	var used_cells = tilemap.get_used_cells(Const.TileCellLayer.INTERACTIVE)
	for coordinate in used_cells:
		source_id = tilemap.get_cell_source_id(Const.TileCellLayer.INTERACTIVE, coordinate)
		atlas_coords = tilemap.get_cell_atlas_coords(Const.TileCellLayer.INTERACTIVE, coordinate)
		# 这个 ID 的瓦片是可被替换的
		id = hash([source_id, atlas_coords])
		if atlas_to_scene_map.has(id):
			scene = atlas_to_scene_map[id]
			var instance = TileMapUtil.replace_tile_as_node_by_scene(
				tilemap, Const.TileCellLayer.INTERACTIVE, coordinate, scene
			)
			if instance is Sewer:
				instance.update_by_tilemap(tilemap)
	
	
	
	

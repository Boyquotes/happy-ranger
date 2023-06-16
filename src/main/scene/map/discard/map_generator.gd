#============================================================
#    Map Generator
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-13 17:40:42
# - version: 4.0
#============================================================
@tool
extends Node2D


var room_block_map_data : MapGenerateUtil.RoomBlockMapData
var rooms : TileMap

var map_size : Vector2i = Vector2i(8, 6)
# 下面两个向量相加为地图房间坐标的偏移值
var room_block_size : Vector2i = Vector2i(16, 13)
var separation : Vector2i = Vector2i(5, 5)



#============================================================
#  内置
#============================================================
func _enter_tree():
	rooms = %rooms
	self.global_position = Vector2(-1000000, -1000000)
	room_block_map_data = MapGenerateUtil.cut_map_room(rooms, room_block_size, separation, 2)


#============================================================
#  SetGet
#============================================================
func get_room_block_map_data() -> MapGenerateUtil.RoomBlockMapData:
	return room_block_map_data


#============================================================
#  自定义
#============================================================
## 生成地图（暂时废弃不用）
func generate(add_to_node: Node = null) -> GeneratedMapData:
	# 地图
	var gene_map : TileMap = BaseMap.new()
	gene_map.tile_set = rooms.tile_set
	if add_to_node:
		add_to_node.add_child(gene_map)

	if room_block_map_data == null:
		room_block_map_data = MapGenerateUtil.cut_map_room(rooms, room_block_size, separation, 2)

	# 生成数据
	var generate_map_data : GeneratedMapData = GeneratedMapData.new()
	generate_map_data.block_room_column_row_size = room_block_size 
	generate_map_data.tilemap = gene_map

	FuncUtil.for_recti(Rect2i(0,0,2,2), func(coords: Vector2i):
		# 生成 9 个 九宫格数据
		var start_pos : Vector2i = MathUtil.get_eight_directionsi().pick_random()
		var data_generator := MapGenerateUtil.nine_grid_room_data_generator(start_pos) as MapGenerateUtil.NineGridRoomDataGenerator
		# 生成到 TileMap 里
		MapGenerateUtil.NineRoomGenerator.generate_by_data(
			room_block_map_data, 
			data_generator, 
			gene_map,
			coords * (room_block_size + Vector2i.ONE) * 3
		)
		# 记录数据
		generate_map_data.add_data(coords, start_pos, data_generator)
	)

	return generate_map_data



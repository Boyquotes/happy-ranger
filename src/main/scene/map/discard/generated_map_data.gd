#============================================================
#    Generate Map Data
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-15 17:04:40
# - version: 4.0
#============================================================
## 生成出的地图的数据
class_name GeneratedMapData


var tilemap : TileMap
## 单元格行列值
var block_room_column_row_size : Vector2i 
## 每个单元格大小
var cell_size: Vector2: 
	get: return tilemap.tile_set.tile_size
## 房间划分单元格
var coords_to_data : Dictionary = {}



##  添加数据
##[br]
##[br][code]coords[/code]  在整体间的九宫格中的坐标
##[br][code]start_pos[/code]  这个块的九宫格开始位置的坐标
##[br][code]data_generator[/code]  当前个房间生成的数据
func add_data(
	coords: Vector2i, 
	start_pos: Vector2i, 
	data_generator: MapGenerateUtil.NineGridRoomDataGenerator
):
	self.coords_to_data[coords] = {
		"start_pos": start_pos,
		"data_generator": data_generator,
	}


func get_room_position(coords: Vector2i) -> Vector2:
	return Vector2( coords * tilemap.tile_set.tile_size )


func get_room_block_start_coords(coords: Vector2i) -> Vector2i:
	return coords_to_data[coords]['start_pos']


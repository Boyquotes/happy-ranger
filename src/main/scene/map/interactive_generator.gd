#============================================================
#    Interactive Generator
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-15 00:08:34
# - version: 4.0
#============================================================
## 可交互的瓦片替换成器
class_name InterractiveGenerator


const Cells = {
	Stairs = [1, Vector2i(0, 3)],
	Spring = [1, Vector2i(1, 8)],
	Chest = [1, Vector2i(35, 26)],
}


var tilemap : TileMap:
	set(v):
		tilemap = v
		offset = tilemap.get_used_rect().position
var offset: Vector2i


#============================================================
#  SetGet
#============================================================
func instance_scene_callback(scene: PackedScene, to: Node) -> Callable:
	return func(coords: Vector2i):
		var instance = scene.instantiate() as Node2D
		instance.global_position = tilemap.map_to_local(coords) - Vector2(0, 8)
		to.add_child(instance)


#============================================================
#  自定义
#============================================================
## 处理替换可交互的对象
static func handle(tilemap: TileMap) -> InterractiveGenerator:
	var g = InterractiveGenerator.new()
	if not tilemap.is_inside_tree():
		await tilemap.tree_entered
	g.execute(tilemap)
	return g


## 执行
func execute(tilemap):
	self.tilemap = tilemap
	
	var current_scene : Node = Engine.get_main_loop().current_scene
	
	# 【地面装饰物】
	
	# 扫描地面以下这些Id和坐标的地面数据
	var used_cells : Array[Vector2i] = []
	used_cells.append_array(tilemap.get_used_cells_by_id(0, 1, Vector2i(1, 0)))
	used_cells.append_array(tilemap.get_used_cells_by_id(0, 1, Vector2i(2, 0)))
	used_cells.append_array(tilemap.get_used_cells_by_id(0, 1, Vector2i(3, 0)))
	used_cells.append_array(tilemap.get_used_cells_by_id(0, 1, Vector2i(3, 1)))
	used_cells.append_array(tilemap.get_used_cells_by_id(0, 1, Vector2i(4, 0)))
	var layers = TileMapUtil.get_layers(tilemap)
	var coords_list : Array[Vector2i] = TileMapUtil.scan_ground(tilemap, layers, used_cells)
	
	# 添加地面装饰物
	var decoration : TileMap = TileMap.new()
	decoration.tile_set = tilemap.tile_set
	decoration.z_index = -1
	current_scene.add_child.call_deferred(decoration)
	for coords in coords_list:
		# 添加概率
		if randf() < 0.25:
			if randf() < 1: #0.3:
				# 创建具有交互性的草
				var grass = add_class_on_cell(coords + Vector2i.UP, Grass, current_scene)
				grass.role = Datas.get_role_scene("slime").instantiate()
				grass.position -= Vector2(8, 8)
				
			else:
				decoration.set_cell(0, coords + Vector2i.UP, 5, Vector2i(randi_range(0, 3), 0))
			
	
	# 【替换交互式瓦片数据】
	
	# 替换楼梯
	replace(Cells.Stairs, func(coords: Vector2i):
		var direction : Vector2i
		var target_coords : Vector2i
		if TileMapUtil.ray_to(tilemap, coords, Vector2i.DOWN, 1) != MathUtil.VECTOR2I_MAX:
			target_coords = TileMapUtil.ray_to(tilemap, coords, Vector2i.UP)
			direction = Vector2i.UP
		else:
			target_coords = TileMapUtil.ray_to(tilemap, coords, Vector2i.DOWN)
			direction = Vector2i.DOWN
		
		if target_coords != MathUtil.VECTOR2I_MAX:
			var instance = add_class_on_cell(coords, Stairs, current_scene) as Stairs
			instance.position -= Vector2(0, 8) * Vector2(direction)
			
			instance.grow(direction, abs(coords.y - target_coords.y) )
	)
	
	# 替换弹簧
	replace(Cells.Spring, instance_scene_callback(ScriptUtil.get_script_scene(Spring), current_scene))
	
	# 替换宝箱
	replace(Cells.Chest, func(coords: Vector2i):
		# 删除
		tilemap.set_cell(Const.TileCellLayer.INTERACTIVE, coords, -1)
		
		# 添加宝箱
		var chest = add_class_on_cell(coords, Chest, current_scene) as Chest
		chest.position += Vector2(0, 8)
		
		# 宝箱中的物品
		for i in randi_range(1, 3):
			var item_data = Datas.get_all_items().pick_random()
			assert(item_data != null)
			chest.add_item(item_data)
		
	)



func add_class_on_cell(coords: Vector2i, _class, current: Node):
	var scene = ScriptUtil.get_script_scene(_class)
	var instance = scene.instantiate()
	current.add_child.call_deferred(instance)
	instance.position = tilemap.map_to_local(coords)
	return instance


## 替换瓦片
##[br]
##[br][code]source_id[/code]  贴图ID
##[br][code]atlas_coords[/code]  地图上的图片坐标
##[br][code]callback[/code]  执行回调，需要有一个 [Vector2i] 类型的参数，接收这个单元格的地图坐标
func replace(data: Array, callback: Callable):
	var source_id: int = data[0]
	var atlas_coords: Vector2i = data[1]
	
	var layer = Const.TileCellLayer.INTERACTIVE
	for coords in tilemap.get_used_cells_by_id(layer, source_id, atlas_coords):
		callback.call(coords)
		tilemap.set_cell(layer, coords, -1, atlas_coords)


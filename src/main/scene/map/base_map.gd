#============================================================
#    Base Map
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-09 20:47:45
# - version: 4.0
#============================================================
@tool
class_name BaseMap
extends TileMap


var __init_tile_set = (func():
	self.tree_entered.connect(func():
		if tile_set == null:
			tile_set = preload("tileset/tile_set.tres")
			texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		# 默认初始化瓦片层级名称，每个 TileMap 统一设置，这样在修改的时候就不用一个个手动修改了
		var diff = Const.TileCellLayer.size() - get_layers_count()
		for i in diff:
			add_layer(-1)
		
		var layer_keys = Const.TileCellLayer.keys()
		for i in Const.TileCellLayer.size():
			if get_layer_name(i) != layer_keys[i]:
				set_layer_name(i, layer_keys[i])
	)
).call()



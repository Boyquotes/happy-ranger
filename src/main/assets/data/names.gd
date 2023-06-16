#============================================================
#    Names
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-11 15:51:31
# - version: 4.x
#============================================================
## 创建随机名称
class_name Names


static func get_random_name() -> String:
	var hashset = DataUtil.singleton("Names_datas", func():
		return HashSet.new(get_foods())
	) as HashSet
	return hashset.pick_random()


static func get_foods() -> Array:
	return DataUtil.singleton("game_foods", func():
		return FileUtil.read_as_text("res://src/main/assets/data/food.txt").split("\n")
	)


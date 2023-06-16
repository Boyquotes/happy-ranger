#============================================================
#    Hash Set
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 10:09:55
# - version: 4.0
#============================================================
## 集合
class_name HashSet


var _data : Dictionary = {}
var _current : int = 0


#============================================================
#  内置
#============================================================
func _init(values = []):
	merge(values)


#func _get(property):
#	if str(property).is_valid_int():
#		return _data.keys()[str(property).to_int()]


func _to_string():
	return str(_data.keys())


#============================================================
#  迭代器
#============================================================
func _iter_init(arg):
	_current = 0
	return _current < _data.size()

func _iter_next(arg):
	_current += 1
	return _current < _data.size()

func _iter_get(arg):
	return _data.keys()[_current]


#============================================================
#  自定义
#============================================================
## 添加元素
func append(value) -> void:
	_data[value] = null

## 添加一组数据
func append_array(values) -> void:
	for value in values:
		_data[value] = null

## 擦除这个数据
func erase(value) -> bool:
	return _data.erase(value)

## 是否有这个值的数据
func has(value) -> bool:
	return _data.has(value)

## 是否存在所有这些数据
func has_all(values) -> bool:
	if values is HashSet:
		return _data.has_all(values.to_array())
	elif values is Array:
		return _data.has_all(values)
	return false

## 转为 [Array] 类型
func to_array() -> Array:
	return _data.keys()

## 数据数量
func size() -> int:
	return _data.size()

## 是否为空的集合
func is_empty() -> bool:
	return _data.is_empty()

## 清除所有数据
func clear() -> void:
	_data.clear()

## 复制一份数据
func duplicate(deep: bool = true) -> HashSet:
	if deep:
		return HashSet.new(_data.keys())
	else:
		var hashset = HashSet.new()
		hashset._data = self._data
		return hashset

## 合并数据
func merge(values) -> void:
	for i in values:
		_data[i] = null

## 数据的哈希值
func hash() -> int:
	return _data.keys().hash()

## 返回一个随机值
func pick_random():
	return _data.keys().pick_random()


#============================================================
#  集合操作
#============================================================
## 是否相同
func equals(hash_set: HashSet) -> bool:
	return self.hash() == hash_set.hash()


## 并集。两个集合中的所有的元素合并后的集合
func union(hash_set: HashSet) -> HashSet:
	var tmp = HashSet.new(_data.keys())
	tmp.merge(hash_set)
	return tmp


## 交集。两个集合中都存在的元素的集合
func intersection(hash_set: HashSet) -> HashSet:
	var list = []
	var tmp = HashSet.new(self.to_array())
	tmp.append_array(hash_set.to_array())
	for item in tmp:
		if has(item) and hash_set.has(item):
			list.append(item)
	return HashSet.new(list)
	

## 差集。两个集合之间存在有不相同的元素的集合
func difference(hash_set: HashSet) -> HashSet:
	var list = []
	var tmp = HashSet.new(self.to_array())
	tmp.append_array(hash_set.to_array())
	for item in tmp:
		if not has(item) or not hash_set.has(item):
			list.append(item)
	return HashSet.new(list)


## 补集/余集。a 集合中不在此集合的元素的集合
func complementary(a: HashSet) -> HashSet:
	var list = []
	if self.has_all(a):
		for item in _data:
			if not a.has(item):
				list.append(item)
	else:
		assert(false, "参数 a 集合不是当前集合的子集")
	return HashSet.new(list)


## 减去集合中的元素后的集合
func subtraction(hash_set: HashSet) -> HashSet:
	var list = []
	for item in _data.keys():
		if not hash_set.has(item):
			list.append(item)
	return HashSet.new(list)


#============================================================
#    F Class
#============================================================
# - datetime: 2022-09-13 14:09:39
#============================================================
## 类信息
class_name FClass


## 是否有大写字符串
static func str_has_upper_char(str: String) -> bool:
	var min = 'a'.unicode_at(0)
	var max = 'z'.unicode_at(0)
	for i in str.length():
		if str.unicode_at(i) >= min && str.unicode_at(i) <= max:
			return true
	return false


## 转为类名。[code]property[/code]参数转为类名
static func property_to_class_name(property: String) -> String:
	return property.capitalize().replace(" ", "")





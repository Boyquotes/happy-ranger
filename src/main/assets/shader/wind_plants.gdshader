// reference: https://godotshaders.com/shader/topdown-windy-plants/
shader_type canvas_item;
render_mode blend_mix;


// 控制最大吹动的强度
uniform vec2 wind = vec2(0, 0);
// 控制被吹动到左右的比值
uniform float offset : hint_range(-1., 1., 0.01) = 0.;


void vertex() {
	VERTEX.y += 1. - UV.y + wind.y;
	VERTEX.x += wind.x * offset * ((1. - UV.y) / VERTEX.y);
}

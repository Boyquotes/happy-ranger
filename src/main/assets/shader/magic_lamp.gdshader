shader_type canvas_item;
render_mode blend_mix;

uniform float time : hint_range(0., 1.0, 0.01) = 0.0;
uniform vec2 left = vec2(0.2, 0.2);
// right 里的 xy 值不能小于 left 的值
uniform vec2 right = vec2(0.4, 0.8);


void fragment(){
	if (COLOR.a > 0.0){
		float targetX = (UV.x - left.x) / (right.x - left.x);
		float targetY = UV.y * ( 1. / pow(1. - max(2. * time - 1., 0.), 2.));
		vec2 targetUV = vec2 (mix(UV.x, targetX, pow(1. - UV.y, 2.) * time), targetY);
		COLOR = texture(TEXTURE, targetUV);
		if(targetUV.x< 0. || targetUV.x>1. || targetUV.y< 0. || targetUV.y>1.){
			COLOR = vec4(0.);
		}
	}
}

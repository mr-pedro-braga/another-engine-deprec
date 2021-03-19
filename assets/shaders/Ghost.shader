shader_type canvas_item;

uniform float opacity;

void fragment() {
	vec2 newuv = UV;
	float d = (0.005*sin(2.0*(newuv.y*6.0+TIME+1.0))); newuv.x += d;
	vec4 col = texture(TEXTURE, newuv) * vec4(2.4, 2.7, 3.0, opacity);
	if(col.a > 0.0) {
		COLOR = col;
	} else {
		discard;
	}
}
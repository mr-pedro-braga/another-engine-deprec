shader_type canvas_item;

//Emission texture
uniform sampler2D emission;
uniform float emission_strength = 1.0;
uniform sampler2D borders;
uniform float border_strength:hint_range(0.0, 1.0) = 0.0;
uniform vec4 emission_tint:hint_color = vec4(1.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec4 emcol = texture(emission, UV) * emission_tint * emission_strength;
	if (emcol.a > 0.0)
		col += emcol;
		vec4 bc = texture(borders, UV) * (sin(UV.x*10.0+TIME*4.0) + cos(UV.y*10.0+TIME*6.2))/4.0+0.5;
		col.xyz += (bc.rgb * bc.a * 2.0 - 0.5) * border_strength;
		col.xyz = mix(col.xyz, col.xxx, border_strength);
	COLOR = col;
}
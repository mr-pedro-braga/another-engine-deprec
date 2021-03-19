shader_type canvas_item;

//Emission texture
uniform sampler2D emission;
uniform float emission_strength = 1.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec4 emcol = texture(emission, UV) * (emission_strength + 0.3 * sin(TIME * 4.0));
	if (emcol.a > 0.0)
		col += emcol;
	COLOR = col;
}
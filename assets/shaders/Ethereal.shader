shader_type canvas_item;

uniform sampler2D iChannel0;

void fragment()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = UV;
	vec2 fragCoord = UV * 1./SCREEN_PIXEL_SIZE;

    float noise = 0.5 + 1.0*textureLod(iChannel0, fragCoord/100.0 + vec2(fract(sin(TIME*163.0+fragCoord.x+fragCoord.y))), 3.0).r;
    
    vec3 col = 1.0 + 0.5*cos(TIME+uv.xyx+vec3(0,2,4));
    col = (col + noise*noise) * 0.3;

    // Output to screen
    COLOR = vec4(col,1.0);
    
    //fragColor.rgb = fragColor.rgb * d;
}
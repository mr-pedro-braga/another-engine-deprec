shader_type canvas_item;

uniform sampler2D noisetexture;

varying float t;

void vertex() {
	t = TIME;
}

float noise(vec2 p)
{
	float s = texture(noisetexture,vec2(1.,2.*cos(t))*t*8. + p*1.).x;
	s *= s;
	return s;
}
float onOff(float a, float b, float c)
{
	return step(c, sin(t + a*cos(t*b)));
}
float ramp(float y, float start, float end)
{
	float inside = step(start,y) - step(end,y);
	float fact = (y-start)/(end-start)*inside;
	return (1.-fact) * inside;
	
}
float stripes(vec2 uv)
{
	float noi = noise(uv*vec2(0.5,1.) + vec2(1.,3.));
	return ramp(mod(uv.y*4. + t/2.+sin(t + sin(t*0.63)),1.),0.5,0.6)*noi*0.2;
}
vec3 getVideo(vec2 uv, sampler2D s, vec2 u)
{
	vec2 look = uv;
	float window = 1./(1.+16.*(look.y-mod(t/4.,1.))*(look.y-mod(t/4.,1.)));
	look.x = look.x + sin(look.y*10. + t)/50.*onOff(4.,4.,.3)*(1.+cos(t*80.))*window;
	float vShift = 0.4*onOff(2.,3.,.9)*(sin(t)*sin(t*20.) + 
										 (0.5 + 0.1*sin(t*200.)*cos(t)));
	look.y = mod(look.y + vShift, 1.);
	vec3 video = texture(s, u + look * 0.06).xyz;
	return video;
}
vec2 screenDistort(vec2 uv)
{
	uv -= vec2(.5,.5);
	uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
	uv += vec2(.5,.5);
	return uv;
}
void fragment( )
{
	vec2 uv = UV;
	uv = screenDistort(uv);
	vec3 video = getVideo(uv, SCREEN_TEXTURE, SCREEN_UV);
	float vigAmt = 3.+.3*sin(t + 5.*cos(t*5.));
	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
	
	video += stripes(uv);
	video += noise(uv*2.)/2.;
	video *= vignette;
	video *= (12.+mod(uv.y*30.+t,1.))/13.;
	
	COLOR = vec4(video,1.0);
}
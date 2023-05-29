shader_type spatial;
render_mode unshaded;

uniform sampler2D mirrorCamTex;

vec3 srgb_conversion(vec3 color) {
	float r = pow(color.r, 2.2);
	float g = pow(color.g, 2.2);
	float b = pow(color.b, 2.2);
	return vec3(r, g, b);
}

void fragment() {
	vec3 color = texture(mirrorCamTex, vec2(UV.x, 1.0 - UV.y)).rgb;
	ALBEDO = srgb_conversion(color);
}

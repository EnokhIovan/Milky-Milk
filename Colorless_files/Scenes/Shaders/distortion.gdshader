shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform float radius : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 uv = UV - center;
	float dist = length(uv);
	
	float pull = smoothstep(radius, 0.0, dist) * distortion_strength;
	vec2 distorted_uv = center + uv * (1.0 - pull);
	
	vec4 col = texture(TEXTURE, distorted_uv);
	
	// vignette hitam di tengah
	float darkness = 1.0 - smoothstep(0.0, radius * 0.6, dist);
	col.rgb = mix(col.rgb, vec3(0.0), darkness);
	col.a = mix(col.a, 1.0, darkness);
	
	COLOR = col;
}
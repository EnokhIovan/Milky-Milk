shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(0.5);

	float dist = distance(uv, center);

	if (dist > 0.5) {
		COLOR = vec4(0.0);
	} else {
		COLOR = COLOR;
	}
}
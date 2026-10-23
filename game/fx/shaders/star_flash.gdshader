shader_type spatial;
// Destello de impacto: estrella de 4 puntas que mira a la cámara, crece y se apaga.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, depth_test_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.6, 1.0);
uniform float fade : hint_range(0.0, 1.0) = 1.0;
uniform float pixel_steps = 24.0;
uniform float energy = 4.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	vec2 uv = (floor(UV * pixel_steps) + 0.5) / pixel_steps;
	vec2 p = abs((uv - 0.5) * 2.0);
	// Cruz fina + rombo central.
	float cross_shape = max(1.0 - smoothstep(0.0, 0.12, p.x) * 1.0, 0.0) * (1.0 - p.y)
		+ max(1.0 - smoothstep(0.0, 0.12, p.y), 0.0) * (1.0 - p.x);
	float diamond = 1.0 - smoothstep(0.25, 0.4, p.x + p.y);
	float a = clamp(cross_shape + diamond, 0.0, 1.0) * fade;
	vec3 col = mix(color.rgb, vec3(1.0), diamond);
	ALBEDO = col * energy * a;
	ALPHA = a;
}

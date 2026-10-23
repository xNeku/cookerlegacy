shader_type spatial;
// Fantasma de un sprite (estela del dash): silueta de un color, que brilla y se apaga.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform vec4 color : source_color = vec4(0.45, 0.75, 1.0, 1.0);
uniform float energy = 1.6;
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	float a = step(0.5, texture(texture_albedo, UV).a) * fade;
	ALBEDO = color.rgb * energy * a;
	ALPHA = a;
}

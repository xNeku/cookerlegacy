shader_type spatial;
// Onda expansiva en el suelo: un anillo que crece y se apaga.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.7, 0.35, 1.0);
// 0 → 1: tamaño del anillo.
uniform float progress = 0.0;
uniform float thickness = 0.12;
uniform float pixel_steps = 64.0;
uniform float energy = 2.5;

void fragment() {
	vec2 uv = UV;
	if (pixel_steps > 0.0) {
		uv = (floor(uv * pixel_steps) + 0.5) / pixel_steps;
	}
	float r = length((uv - 0.5) * 2.0);
	float radius = progress;
	float w = thickness * (1.0 - progress * 0.6);
	float band = 1.0 - smoothstep(w * 0.4, w, abs(r - radius));
	float a = band * (1.0 - progress);
	ALBEDO = color.rgb * energy * a;
	ALPHA = a;
}

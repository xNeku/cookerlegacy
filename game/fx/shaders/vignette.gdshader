shader_type canvas_item;
// Viñeta: oscurece las esquinas de la pantalla para centrar la mirada.
uniform vec4 color : source_color = vec4(0.02, 0.02, 0.06, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.55;
uniform float radius = 0.75;
uniform float softness = 0.55;

void fragment() {
	vec2 p = (UV - 0.5) * vec2(1.6, 1.0);
	float d = length(p);
	float v = smoothstep(radius - softness, radius, d);
	COLOR = vec4(color.rgb, v * strength);
}

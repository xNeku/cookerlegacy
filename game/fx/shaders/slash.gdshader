shader_type spatial;
// Tajo del arma, dibujado sin textura: un arco en el suelo que barre y deja estela.
// En un PlaneMesh de 1×1 (UV 0..1): el centro es el atacante, +X local = hacia delante.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.85, 0.55, 1.0);
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 0.95, 1.0);
uniform float arc_degrees = 150.0;
uniform float inner_radius = 0.32;
uniform float outer_radius = 1.0;
// 0 → 1: avance del barrido.
uniform float progress = 0.0;
// 1 → 0: se apaga.
uniform float fade = 1.0;
// Largo de la estela (fracción del arco).
uniform float trail = 0.75;
// 1 o -1: sentido del barrido.
uniform float flip = 1.0;
// Píxeles del efecto de lado a lado (0 = suave). Igual que el arte: 32 px por metro.
uniform float pixel_steps = 58.0;
uniform float energy = 3.0;

void fragment() {
	vec2 uv = UV;
	if (pixel_steps > 0.0) {
		uv = (floor(uv * pixel_steps) + 0.5) / pixel_steps;
	}
	vec2 p = (uv - 0.5) * 2.0;
	float r = length(p);
	float ang = degrees(atan(p.y, p.x)) * flip;
	float t = (ang + arc_degrees * 0.5) / arc_degrees;
	float inside = step(0.0, t) * step(t, 1.0);
	// Estela: brillante en la cabeza del barrido, se desvanece hacia atrás.
	float along = clamp((t - (progress - trail)) / max(trail, 0.001), 0.0, 1.0) * step(t, progress) * inside;
	along = pow(along, 1.6);
	float mid = (inner_radius + outer_radius) * 0.5;
	float half_w = (outer_radius - inner_radius) * 0.5 * mix(0.35, 1.0, along);
	float d = abs(r - mid);
	float band = 1.0 - smoothstep(half_w * 0.55, half_w, d);
	float a = along * band * fade;
	float core = step(0.82, along) * (1.0 - smoothstep(0.0, half_w * 0.45, d));
	vec3 col = mix(color.rgb, core_color.rgb, core);
	ALBEDO = col * energy * a;
	ALPHA = a;
}

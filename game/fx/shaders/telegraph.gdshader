shader_type spatial;
// Aviso de ataque enemigo en el suelo: el área donde va a pegar, que se llena hasta el golpe.
// En un PlaneMesh de 1×1 escalado al área; se llena desde atrás (-X) hacia delante (+X).
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 0.25, 0.2, 1.0);
// 0 → 1: avance del aviso.
uniform float progress = 0.0;
uniform float edge = 0.08;
uniform float base_alpha = 0.08;
uniform float energy = 1.3;

void fragment() {
	vec2 p = UV;
	float border = step(p.x, edge) + step(1.0 - edge, p.x) + step(p.y, edge * 1.5) + step(1.0 - edge * 1.5, p.y);
	border = clamp(border, 0.0, 1.0);
	float fill = step(p.x, progress);
	float a = max(base_alpha + fill * 0.14, border * (0.35 + 0.55 * progress));
	// Parpadea al final para avisar de que ya va.
	a *= mix(1.0, 0.6 + 0.4 * sin(TIME * 40.0), step(0.8, progress));
	ALBEDO = color.rgb * energy;
	ALPHA = a;
}

shader_type spatial;
// Agua de río pixelada: color base, brillos que corren con la corriente y orilla clara.
// Se pinta en coordenadas de mundo (sin UV), así que el plano se puede estirar sin deformarla.

uniform vec4 deep_color : source_color = vec4(0.13, 0.32, 0.46, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.22, 0.48, 0.6, 1.0);
uniform vec4 shine_color : source_color = vec4(0.72, 0.9, 0.98, 1.0);
// Dirección y velocidad de la corriente (m/s, en el suelo X/Z).
uniform vec2 flow = vec2(0.0, 0.6);
// Píxeles por metro (32 = como el resto del arte).
uniform float pixels_per_meter = 32.0;
// Cuántos brillos hay (más alto = más).
uniform float shine_amount : hint_range(0.0, 1.0) = 0.12;
uniform float alpha : hint_range(0.0, 1.0) = 0.92;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	// Cuadricula de píxeles de arte.
	vec2 p = floor(world_pos.xz * pixels_per_meter) / pixels_per_meter;
	vec2 moving = p - flow * TIME;
	float n = noise(moving * vec2(1.6, 0.5)) * 0.6 + noise(moving * vec2(3.1, 1.2) + 7.0) * 0.4;
	vec3 col = mix(deep_color.rgb, shallow_color.rgb, smoothstep(0.35, 0.75, n));
	float streak = noise(moving * vec2(5.0, 1.2) + vec2(0.0, TIME * 0.3));
	col = mix(col, shine_color.rgb, step(1.0 - shine_amount, streak));
	ALBEDO = col;
	ROUGHNESS = 0.25;
	SPECULAR = 0.6;
	ALPHA = alpha;
}

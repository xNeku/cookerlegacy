shader_type spatial;
// Sprite de personaje en el mundo 3D (estilo HD-2D):
// - mira siempre a la cámara (billboard), girando sobre los pies;
// - recibe luces y sombras de la escena y proyecta su sombra;
// - flash (golpe recibido) y tinte (dash, carga, aviso) que brillan con el bloom.
// La textura la pone SpriteFX (Godot no se la pasa sola a un shader propio).
render_mode cull_disabled, diffuse_lambert_wrap, specular_disabled;

uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform bool billboard = true;
uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint_color : source_color = vec4(1.0, 0.55, 0.2, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.0;
// Cuánto brillan flash y tinte (más de 1 = bloom).
uniform float glow_energy = 2.5;
// Luz propia mínima: que el personaje se lea aunque esté lejos de las antorchas.
uniform float self_light : hint_range(0.0, 1.0) = 0.12;

void vertex() {
	if (billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
}

void fragment() {
	vec4 c = texture(texture_albedo, UV) * COLOR;
	vec3 col = mix(c.rgb, tint_color.rgb, tint_amount * 0.35);
	col = mix(col, flash_color.rgb, flash_amount);
	ALBEDO = col;
	EMISSION = c.rgb * self_light
		+ tint_color.rgb * tint_amount * glow_energy * 0.28
		+ flash_color.rgb * flash_amount * glow_energy;
	ALPHA = c.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}

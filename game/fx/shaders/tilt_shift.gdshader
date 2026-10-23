shader_type canvas_item;
// Tilt-shift en pantalla (look HD-2D / maqueta): franja nítida horizontal y desenfoque
// creciente hacia arriba y hacia abajo. No depende de la profundidad: barato y estable.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
// Centro de la franja nítida (0 = arriba, 1 = abajo de la pantalla).
uniform float focus_center : hint_range(0.0, 1.0) = 0.56;
// Alto de la franja nítida (fracción de pantalla).
uniform float focus_height : hint_range(0.0, 1.0) = 0.36;
// Cuánto tarda en llegar al desenfoque máximo fuera de la franja.
uniform float falloff : hint_range(0.01, 1.0) = 0.3;
// Desenfoque máximo arriba y abajo (nivel de mipmap; 0 = nada, 3 = mucho).
uniform float blur_top : hint_range(0.0, 5.0) = 2.6;
uniform float blur_bottom : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	float d = SCREEN_UV.y - focus_center;
	float t = smoothstep(focus_height * 0.5, focus_height * 0.5 + falloff, abs(d));
	float lod = t * (d < 0.0 ? blur_top : blur_bottom);
	vec2 o = SCREEN_PIXEL_SIZE * exp2(lod) * 0.75;
	vec3 c = textureLod(screen_tex, SCREEN_UV, lod).rgb * 0.36;
	c += textureLod(screen_tex, SCREEN_UV + vec2(o.x, o.y), lod).rgb * 0.16;
	c += textureLod(screen_tex, SCREEN_UV + vec2(-o.x, o.y), lod).rgb * 0.16;
	c += textureLod(screen_tex, SCREEN_UV + vec2(o.x, -o.y), lod).rgb * 0.16;
	c += textureLod(screen_tex, SCREEN_UV + vec2(-o.x, -o.y), lod).rgb * 0.16;
	COLOR = vec4(c, 1.0);
}

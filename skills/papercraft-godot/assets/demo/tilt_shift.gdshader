shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float focus_y : hint_range(0.0, 1.0) = 0.55;
uniform float sharp_band : hint_range(0.0, 1.0) = 0.31;
uniform float max_blur_px : hint_range(0.0, 24.0) = 10.0;
uniform vec4 warm_corner : source_color = vec4(0.37, 0.22, 0.12, 1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	float d = abs(uv.y - focus_y);
	float amount = smoothstep(sharp_band * 0.5, 0.56, d);
	amount = amount * amount * (3.0 - 2.0 * amount);
	vec2 radius = SCREEN_PIXEL_SIZE * max_blur_px * amount;

	vec3 col = texture(screen_texture, uv).rgb * 0.20;
	float weight = 0.20;
	for (int i = 0; i < 12; i++) {
		float angle = float(i) * 0.5235987756;
		float ring = i % 2 == 0 ? 0.55 : 1.0;
		vec2 offset = vec2(cos(angle), sin(angle)) * radius * ring;
		col += texture(screen_texture, uv + offset).rgb * 0.0666667;
		weight += 0.0666667;
	}
	col /= weight;

	vec2 vignette_uv = (uv - 0.5) * vec2(1.0, 1.045);
	float vignette = smoothstep(0.43, 0.76, length(vignette_uv));
	vec3 corner_tint = warm_corner.rgb / vec3(0.37, 0.22, 0.12);
	col = mix(col, col * corner_tint, vignette * 0.18);
	COLOR = vec4(col, 1.0);
}

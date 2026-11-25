shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;

uniform sampler2D artwork : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 kraft_color : source_color = vec4(0.72, 0.62, 0.46, 1.0);
uniform vec4 leak_color : source_color = vec4(0.44, 0.25, 0.12, 1.0);
uniform float wrap = 0.30;
uniform float grain_strength = 0.035;
uniform float seed_value = 0.0;
uniform float flash = 0.0;
uniform float bounce_energy : hint_range(0.0, 0.4) = 0.13;

float hash21(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 34.5);
	return fract(p.x * p.y);
}

float paper_noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i + seed_value);
	float b = hash21(i + vec2(1.0, 0.0) + seed_value);
	float c = hash21(i + vec2(0.0, 1.0) + seed_value);
	float d = hash21(i + vec2(1.0, 1.0) + seed_value);
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y) - 0.5;
}

void fragment() {
	vec3 print_rgb = texture(artwork, UV).rgb;
	float broad_fibre = paper_noise(UV * 7.0 + vec2(seed_value, -seed_value)) * grain_strength;
	float fine_fibre = paper_noise(UV * vec2(173.0, 211.0) + seed_value * 3.7) * grain_strength * 0.55;
	print_rgb += vec3(broad_fibre + fine_fibre);

	if (!FRONT_FACING) {
		print_rgb = mix(kraft_color.rgb, print_rgb * 0.68, 0.22);
	}

	print_rgb = mix(print_rgb, vec3(1.0, 0.93, 0.72), flash * 0.55);
	ALBEDO = clamp(print_rgb, vec3(0.0), vec3(1.0));
	EMISSION = ALBEDO * vec3(1.03, 0.96, 0.84) * bounce_energy;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	SPECULAR = 0.0;
}

void light() {
	float nl = dot(NORMAL, LIGHT);
	float front = clamp((nl + wrap) / (1.0 + wrap), 0.0, 1.0);
	vec3 bounced = mix(leak_color.rgb, vec3(1.0), ATTENUATION);
	DIFFUSE_LIGHT += front * LIGHT_COLOR * bounced / PI;
}

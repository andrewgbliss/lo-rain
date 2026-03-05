shader_type canvas_item;

uniform vec4 color_low : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_high : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float threshold = 0.5;
uniform float hp : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 result = mix(color_low, color_high, hp);
	COLOR = vec4(result.rgb, result.a * COLOR.a);
}

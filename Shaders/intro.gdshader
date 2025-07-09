shader_type canvas_item;

uniform float time;
uniform float noise_strength = 0.2;
uniform float scanline_strength = 0.1;
uniform float scanline_frequency = 300.0;

void fragment() {
	// Static noise
	float noise = fract(sin(dot(UV * TIME * 100.0, vec2(12.9898,78.233))) * 43758.5453);
	
	// Scanlines
	float scanline = sin(UV.y * scanline_frequency) * scanline_strength;

	// Final grayscale value with noise and scanlines
	float final = noise * noise_strength + scanline;

	COLOR = vec4(vec3(final), 1.0);
}

shader_type canvas_item;

uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.5; // Intensity of the scanlines
uniform float scanline_speed : hint_range(0.0, 1.0) = 0.1; // Speed of scanline animation

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Animate scanlines by making them move over time based on a sine wave
    float scanline = sin(UV.y * SCREEN_PIXEL_SIZE.y * 40.0 + TIME * scanline_speed * 10.0) * 0.5 + 0.5; // Adjust speed with scanline_speed
    scanline = mix(1.0, scanline, scanline_intensity); // Adjust intensity of scanlines
    
    // Apply scanline effect to texture color
    tex_color.rgb *= scanline; // Apply scanline effect to color
    
    // Output final color
    COLOR = tex_color;
}

shader_type canvas_item;

uniform float line_thickness : hint_range(0, 20) = 1.0;    
uniform float sin_frequency : hint_range(0.1, 2.0) = 0.5; 
uniform float sin_offset : hint_range(0.0, 360.0) = 0.0;   
uniform float light_offset : hint_range(0.0, 1.0) = 0.5;  

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    
    float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    outline = min(outline, 1.0);
    
    vec4 gold_color = vec4(1.0, 0.843, 0.0, 1.0); // Gold color
    vec4 white_color = vec4(1.0, 1.0, 1.0, 1.0); // White color
    vec4 black_color = vec4(0.0, 0.0, 0.0, 1.0); // Black color
    
    vec4 animated_line_color = mix(white_color, gold_color, light_offset + sin(2.0 * 3.14 * sin_frequency * TIME));
    vec4 color = texture(TEXTURE, UV);
    COLOR = mix(color, animated_line_color, outline - color.a);
}

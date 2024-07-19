shader_type canvas_item;

uniform float blink_speed : hint_range(0.1, 10.0) = 1.0; 
uniform float blink_intensity : hint_range(0.0, 1.0) = 1.0; 

void fragment() {

    float blink_factor = abs(sin(TIME * blink_speed));
    
    vec4 original_color = texture(TEXTURE, UV);
    vec4 final_color = mix(original_color, vec4(0.0, 0.0, 0.0, 0.0), blink_factor * blink_intensity);
    
    COLOR = final_color;
}

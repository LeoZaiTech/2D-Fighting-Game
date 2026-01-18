shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.9;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Check if pixel is close to white
    float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    
    if (brightness > threshold && tex_color.r > threshold && tex_color.g > threshold && tex_color.b > threshold) {
        // Make white pixels transparent
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        COLOR = tex_color;
    }
}

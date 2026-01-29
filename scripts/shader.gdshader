shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float tolerance : hint_range(0.0, 0.9) = 0.05;

// Questi sono i due colori nuovi che sceglierai tu nell'Inspector
uniform vec4 color_bg : source_color;
uniform vec4 color_fg : source_color;

void fragment() {
    vec4 tex_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec3 rgb = tex_color.rgb;

    // 1. Definiamo i colori sorgente (Hardcoded per velocità)
    vec3 teal_originale = vec3(0.47, 0.79, 0.77);   // #78c9c4
    vec3 yellow_originale = vec3(1.0, 0.80, 0.0);  // #ffcc00
    vec3 bianco = vec3(1.0, 1.0, 1.0);              // #ffffff

    // 2. Logica di sostituzione rapida
    if (distance(rgb, bianco) < tolerance) {
        COLOR = vec4(rgb, tex_color.a); // Resta Bianco
    } 
    else if (distance(rgb, teal_originale) < tolerance) {
        COLOR = vec4(color_bg.rgb, tex_color.a); // Diventa il tuo nuovo colore A
    } 
    else if (distance(rgb, yellow_originale) < tolerance) {
        COLOR = vec4(color_fg.rgb, tex_color.a); // Diventa il tuo nuovo colore B
    } 
    else {
        // 3. Effetto seppia per tutto il resto
        float gray = dot(rgb, vec3(0.299, 0.587, 0.114));
        COLOR = vec4(vec3(gray) * vec3(1.2, 1.0, 0.8), tex_color.a);
    }
}
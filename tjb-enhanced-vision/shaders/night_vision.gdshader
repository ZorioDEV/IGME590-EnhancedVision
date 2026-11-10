shader_type canvas_item;

uniform float brightness : hint_range(0.0, 3.0) = 1.5;
uniform float contrast : hint_range(0.0, 3.0) = 1.2;
uniform vec3 night_vision_color : source_color = vec3(0.1, 1.0, 0.2);
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;
uniform float scanline_density : hint_range(0.0, 1000.0) = 300.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.15;
uniform float grain_size : hint_range(1.0, 10.0) = 3.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float animated_noise(vec2 uv, float time) {
    return noise(uv + time * 0.1) * noise(uv * 2.0 + time * 0.05);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 screen_color = texture(SCREEN_TEXTURE, uv);
    float luminance = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
    luminance = (luminance - 0.5) * contrast + 0.5;
    luminance *= brightness;
    vec3 color = luminance * night_vision_color;
    float scanline = sin(uv.y * scanline_density) * 0.5 + 0.5;
    scanline = pow(scanline, 3.0);
    color *= 1.0 - scanline_intensity * (1.0 - scanline);
    float grain = animated_noise(uv * grain_size, TIME);
    color += (grain - 0.5) * noise_strength;
    vec2 center = uv - vec2(0.5);
    float vignette = 1.0 - dot(center, center) * vignette_strength;
    vignette = smoothstep(0.0, 1.0, vignette);
    color *= vignette;
    
    float dist_from_center = length(center);
    color = clamp(color, 0.0, 1.0);
    
    COLOR = vec4(color, screen_color.a);
}
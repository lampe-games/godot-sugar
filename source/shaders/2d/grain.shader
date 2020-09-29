shader_type canvas_item;

uniform sampler2D grain_texture : hint_black;
uniform float grain_strength : hint_range(0.0, 1.0) = 0.1;
uniform float grain_size : hint_range(1.0, 10.0) = 1.0;

void fragment()
{
  vec3 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  vec2 screen_pixel = SCREEN_UV * SCREEN_PIXEL_SIZE;
  vec2 grain_to_screen_ratio =
      vec2(textureSize(grain_texture, 0)) / vec2(textureSize(SCREEN_TEXTURE, 0)) * grain_size;
  vec2 periodic_grain_texture_uv = mod(SCREEN_UV, grain_to_screen_ratio) / grain_to_screen_ratio;
  vec3 grain_color = textureLod(grain_texture, periodic_grain_texture_uv, 0.0).rgb;
  COLOR.rgb = clamp(color - grain_strength * grain_color, vec3(0.0), vec3(1.0));
}

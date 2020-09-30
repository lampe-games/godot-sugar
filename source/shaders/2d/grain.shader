shader_type canvas_item;

uniform sampler2D grain_texture : hint_black;
uniform sampler2D grain_gradient_texture : hint_black;
uniform float grain_strength : hint_range(0.0, 1.0) = 0.1;
uniform float grain_size : hint_range(1.0, 10.0) = 1.0;
uniform int sub_mix_add : hint_range(0, 2) = 0;

void fragment()
{
  vec3 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  vec2 grain_to_screen_ratio =
      vec2(textureSize(grain_texture, 0)) / vec2(textureSize(SCREEN_TEXTURE, 0)) * grain_size;
  vec2 periodic_grain_texture_uv = mod(SCREEN_UV, grain_to_screen_ratio) / grain_to_screen_ratio;
  float grain_value = textureLod(grain_texture, periodic_grain_texture_uv, 0.0).r;
  vec3 grain_color = textureLod(grain_gradient_texture, vec2(grain_value, 0.0), 0.0).rgb;
  if (sub_mix_add == 0)
  {
    COLOR.rgb = clamp(color - grain_strength * grain_color, vec3(0.0), vec3(1.0));
  }
  else if (sub_mix_add == 1)
  {
    COLOR.rgb = mix(color, grain_color, grain_strength);
  }
  else
  {
    COLOR.rgb = clamp(color + grain_strength * grain_color, vec3(0.0), vec3(1.0));
  }
}

shader_type canvas_item;

// https://en.wikipedia.org/wiki/Ordered_dithering

uniform int palette_colors : hint_range(2, 32) = 2;
uniform float color_space_spread : hint_range(0.0, 256.0) = 0.5;
uniform sampler2D palette_texture : hint_black;
uniform sampler2D dither_pattern_texture : hint_black; // aka Bayer matrix

void fragment()
{
  vec3 original_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  vec2 pattern_to_screen_ratio =
      vec2(textureSize(dither_pattern_texture, 0)) / vec2(textureSize(SCREEN_TEXTURE, 0));
  vec2 periodic_pattern_texture_uv =
      mod(SCREEN_UV, pattern_to_screen_ratio) / pattern_to_screen_ratio;
  float dither_threshold = textureLod(dither_pattern_texture, periodic_pattern_texture_uv, 0.0).r;
  vec3 estimated_color = original_color + color_space_spread * (dither_threshold - 0.5);
  vec3 nearest_palette_color = textureLod(palette_texture, vec2(0.0), 0.0).rgb;
  float min_distance = distance(estimated_color, nearest_palette_color);
  for (int i = 1; i < palette_colors; i++)
  {
    vec3 candidate_color =
        textureLod(palette_texture, vec2(float(i) / float(palette_colors - 1)), 0.0).rgb;
    float a_distance = distance(estimated_color, candidate_color);
    if (a_distance < min_distance)
    {
      nearest_palette_color = candidate_color;
      min_distance = a_distance;
    }
  }
  COLOR.rgb = nearest_palette_color;
}

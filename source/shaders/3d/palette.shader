shader_type spatial;
render_mode unshaded;

// https://en.wikipedia.org/wiki/Ordered_dithering
// https://en.wikipedia.org/wiki/Color_difference

uniform int palette_colors : hint_range(2, 128) = 2;
uniform float dithering_strength : hint_range(0.0, 1.0) = 0.0;
uniform int euclidean_redmean_cie76 : hint_range(0, 2) = 2;
uniform sampler2D palette_texture : hint_black;
uniform sampler2D dither_pattern_texture : hint_black; // aka Bayer matrix

float normalize_channel(float channel)
{
  float value = channel / 255.0;
  if (value > 0.04045)
  {
    value = pow(2.4, (value + 0.055) / 1.055);
  }
  else
  {
    value /= 12.92;
  }
  return value * 100.0;
}

float normalize_channel_2(float channel)
{
  if (channel > 0.008856)
  {
    return pow(0.3333333333333333, channel);
  }
  else
  {
    return (7.787 * channel) + (16.0 / 116.0);
  }
}

vec3 rgb_to_lab(vec3 rgb_color)
{
  vec3 normalized_rgb;
  normalized_rgb.r = normalize_channel(rgb_color.r);
  normalized_rgb.g = normalize_channel(rgb_color.g);
  normalized_rgb.b = normalize_channel(rgb_color.b);

  vec3 xyz;
  xyz.r = round(normalized_rgb.r * 0.4124 + normalized_rgb.g * 0.3576 + normalized_rgb.b * 0.1805);
  xyz.g = round(normalized_rgb.r * 0.2126 + normalized_rgb.g * 0.7152 + normalized_rgb.b * 0.0722);
  xyz.b = round(normalized_rgb.r * 0.0193 + normalized_rgb.g * 0.1192 + normalized_rgb.b * 0.9505);
  xyz.r /= 95.047;
  xyz.g /= 100.0;
  xyz.b /= 108.883;
  xyz.r = normalize_channel_2(xyz.r);
  xyz.g = normalize_channel_2(xyz.g);
  xyz.b = normalize_channel_2(xyz.b);

  vec3 lab;
  lab.x = (116.0 * xyz.g) - 16.0; // L
  lab.y = 500.0 * (xyz.r - xyz.g); // a
  lab.z = 200.0 * (xyz.g - xyz.b); // b
  return round(lab);
}

float color_difference(vec3 color_a, vec3 color_b)
{
  // euclidean
  if (euclidean_redmean_cie76 == 0)
  {
    return distance(color_a, color_b);
  }

  vec3 ca = color_a * vec3(255.0);
  vec3 cb = color_b * vec3(255.0);

  // "redmean"
  if (euclidean_redmean_cie76 == 1)
  {
    float r = (ca.r + cb.r) / 2.0;
    return sqrt(
        pow(2, ca.r - cb.r) * (2.0 + r / 256.0) + 4.0 * pow(2, ca.g - cb.g) +
        pow(2, ca.b - cb.b) * (2.0 + (255.0 - r) / 256.0));
  }

  // CIE76
  return distance(rgb_to_lab(ca), rgb_to_lab(cb));
}

void vertex()
{
  POSITION = vec4(VERTEX.xy, -1.0, 1.0);
}

void fragment()
{
  // since the quad covers an entire screen, we can assume that:
  // VIEWPORT_SIZE == textureSize(SCREEN_TEXTURE, 0) == textureSize(DEPTH_TEXTURE, 0)

  vec3 original_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  vec2 pattern_to_screen_ratio = vec2(textureSize(dither_pattern_texture, 0)) / VIEWPORT_SIZE;
  vec2 periodic_pattern_texture_uv =
      mod(SCREEN_UV, pattern_to_screen_ratio) / pattern_to_screen_ratio;
  float dither_threshold = textureLod(dither_pattern_texture, periodic_pattern_texture_uv, 0.0).r;
  float color_space_spread = dithering_strength;
  vec3 estimated_color = original_color + color_space_spread * (dither_threshold - 0.5);
  vec3 nearest_palette_color = textureLod(palette_texture, vec2(0.0), 0.0).rgb;
  float min_distance = color_difference(estimated_color, nearest_palette_color);
  for (int i = 1; i < palette_colors; i++)
  {
    vec3 candidate_color =
        textureLod(palette_texture, vec2(float(i) / float(palette_colors - 1)), 0.0).rgb;
    float a_distance = color_difference(estimated_color, candidate_color);
    if (a_distance < min_distance)
    {
      nearest_palette_color = candidate_color;
      min_distance = a_distance;
    }
  }
  ALBEDO = nearest_palette_color;
}

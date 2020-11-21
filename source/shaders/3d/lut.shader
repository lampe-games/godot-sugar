shader_type spatial;
render_mode unshaded;

// inspired by blog post (with some tweaks added):
// http://halisavakis.com/my-take-on-shaders-color-grading-with-look-up-textures-lut/

uniform sampler2D lut_texture : hint_black;
uniform float lut_color_contribution : hint_range(0.0, 1.0) = 1.0;
uniform bool lut_horizontal_flip = false;

void vertex()
{
  POSITION = vec4(VERTEX.xy, -1.0, 1.0);
}

void fragment()
{
  vec3 original_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  ivec2 lut_texture_size = textureSize(lut_texture, 0);
  float lut_cell_size = float(lut_texture_size.y);
  vec2 lut_texel_half = vec2(0.5) / vec2(lut_texture_size);
  float x_cell = (ceil(original_color.b * lut_cell_size) - 1.0) / lut_cell_size;
  vec2 lut_uv = vec2(
      lut_texel_half.x + x_cell +
          (ceil(original_color.r * lut_cell_size) - 1.0) / lut_cell_size / lut_cell_size,
      lut_texel_half.y + (1.0 - original_color.g) * float(!lut_horizontal_flip) +
          original_color.g * float(lut_horizontal_flip));
  ALBEDO = mix(original_color, textureLod(lut_texture, lut_uv, 0.0).rgb, lut_color_contribution);
}

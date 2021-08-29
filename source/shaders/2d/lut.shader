shader_type canvas_item;

// inspired by blog post (with some tweaks added):
// http://halisavakis.com/my-take-on-shaders-color-grading-with-look-up-textures-lut/

uniform sampler2D lut_texture : hint_black;
uniform float lut_color_contribution : hint_range(0.0, 1.0) = 1.0;
uniform bool lut_horizontal_flip = false;

void fragment()
{
  // reference implementation on integers:
  // ivec2 lut_texture_size = textureSize(lut_texture, 0); // suppose 1024x32
  // int lut_cell_size = lut_texture_size.y; // i<32>
  // vec3 original_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  // ivec3 ioriginal_color = ivec3(round(original_color * float(lut_cell_size - 1))); // (i<0;31>;;)
  // int x_cell = ioriginal_color.b; // i<0;31>
  // // 0..31, 32*1..32*1+31, ..., 32*31..32*31+31
  // int xa = x_cell * lut_cell_size; // i<0;31*32>
  // int xb = ioriginal_color.r; // i<0;31>
  // int x = xa + xb; // i<0;31*32+31>
  // float fx = (float(x) + 0.5) / float(lut_texture_size.x); // f<lth;1023+lth> / f<1024>
  // int y = ioriginal_color.g; // i<0;31>
  // float fy = (float(y) + 0.5) / float(lut_texture_size.y); // f<lth;31+lth> / f<32>
  // fy = (1.0 - fy) * float(!lut_horizontal_flip) + fy * float(lut_horizontal_flip);
  // vec2 lut_uv = vec2(fx, fy);
  // vec3 actual_color = textureLod(lut_texture, lut_uv, 0.0).rgb;
  // COLOR.rgb = mix(original_color, actual_color, lut_color_contribution);

  // stable implementation on floats
  vec3 original_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  vec2 lut_texture_size = vec2(textureSize(lut_texture, 0)); // suppose 1024x32
  float lut_cell_size = lut_texture_size.y; // f<32>
  vec3 foriginal_color = original_color * (lut_cell_size - 1.0); // (f<0;31>;;)
  vec2 lut_texel_half = vec2(0.5) / vec2(lut_texture_size); // e.g. 0.25 for 2 texels
  float x_base = round(foriginal_color.b) * lut_cell_size; // f<0;31*32>
  float lut_uv_x = (x_base + foriginal_color.r) / lut_texture_size.x + lut_texel_half.x;
  float lut_uv_y = foriginal_color.g / lut_texture_size.y + lut_texel_half.y;
  lut_uv_y = (1.0 - lut_uv_y) * float(!lut_horizontal_flip) + lut_uv_y * float(lut_horizontal_flip);
  vec2 lut_uv = vec2(lut_uv_x, lut_uv_y);
  COLOR.rgb = mix(original_color, textureLod(lut_texture, lut_uv, 0.0).rgb, lut_color_contribution);
}

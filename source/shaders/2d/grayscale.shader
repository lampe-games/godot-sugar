shader_type canvas_item;

void fragment()
{
  vec3 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  float luminance = color.r * 0.3 + color.g * 0.59 + color.b * 0.11;
  COLOR.rgb = vec3(luminance);
}

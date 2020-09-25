shader_type canvas_item;

uniform float blurr_factor : hint_range(0.0, 10.0) = 2.0;
uniform bool remove_alpha = true;

void fragment()
{
  vec4 blurred_color;
  blurred_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blurr_factor);
  if (remove_alpha)
  {
    COLOR.rgb = blurred_color.rgb;
  }
  else
  {
    COLOR = blurred_color;
  }
}

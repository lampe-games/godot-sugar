shader_type canvas_item;

uniform int pixels_to_cluster : hint_range(1, 9999) = 1;
uniform bool blurr = false;

void fragment()
{
  vec2 uv = SCREEN_UV;
  uv -= mod(uv, SCREEN_PIXEL_SIZE * float(pixels_to_cluster));
  vec2 mid_offset = SCREEN_PIXEL_SIZE * float(pixels_to_cluster) / 2.0;
  uv += mid_offset;
  vec3 color = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
  if (blurr)
  {
    color += textureLod(SCREEN_TEXTURE, uv - mid_offset, 0.0).rgb;
    color += textureLod(SCREEN_TEXTURE, uv + mid_offset, 0.0).rgb;
    color += textureLod(SCREEN_TEXTURE, uv + vec2(-mid_offset.x, mid_offset.y), 0.0).rgb;
    color += textureLod(SCREEN_TEXTURE, uv + vec2(+mid_offset.x, -mid_offset.y), 0.0).rgb;
    color /= 5.0;
  }
  COLOR.rgb = color;
}

shader_type canvas_item;

void fragment()
{
  vec3 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
  mat3 sepiaWeights =
      mat3(vec3(0.393, 0.349, 0.272), vec3(0.769, 0.686, 0.534), vec3(0.189, 0.168, 0.131));
  COLOR.rgb = sepiaWeights * color.rgb;
}

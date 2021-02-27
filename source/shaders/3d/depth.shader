shader_type spatial;
render_mode unshaded;

void vertex()
{
  POSITION = vec4(VERTEX.xy, -0.5, 0.5);
}

void fragment()
{
  // depth is encoded on the red channel within <0;1> range
  float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).x;
  ALBEDO = vec3(1.0 - depth, vec2(0.0));
}

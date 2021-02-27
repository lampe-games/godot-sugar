shader_type spatial;
render_mode unshaded;

uniform float darken_strength : hint_range(0.0, 1.0) = 0.95;

void vertex()
{
  POSITION = vec4(VERTEX.xy, -0.5, 0.5);
}

void fragment()
{
  ALBEDO = vec3(0.0);
  ALPHA = darken_strength;
}

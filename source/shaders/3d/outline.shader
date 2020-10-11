shader_type spatial;
render_mode unshaded;

// based on: https://roystan.net/articles/outline-shader.html

uniform float outline_scale : hint_range(1.0, 10.0) = 1.0;
uniform float depth_threshold : hint_range(0.0, 10.0) = 1.0;
uniform float depth_threshold_low : hint_range(0.0, 10.0) = 1.0;
uniform float depth_threshold_high : hint_range(0.0, 10.0) = 1.0;
uniform float color_threshold : hint_range(0.0, 1.0) = 0.1;
uniform vec4 outline_color : hint_color = vec4(1.0);

void vertex()
{
  POSITION = vec4(VERTEX.xy, -1.0, 1.0);
}

void fragment()
{
  // since the quad covers an entire screen, we can assume that:
  // VIEWPORT_SIZE == textureSize(SCREEN_TEXTURE, 0) == textureSize(DEPTH_TEXTURE, 0)

  ALBEDO = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;

  vec2 pixel_size = vec2(1.0) / VIEWPORT_SIZE;
  float half_scale_floor = floor(outline_scale * 0.5);
  float half_scale_ceil = ceil(outline_scale * 0.5);

  vec2 bottom_left_sample_uv = SCREEN_UV - pixel_size * half_scale_floor;
  vec2 top_right_sample_uv = SCREEN_UV + pixel_size * half_scale_ceil;
  vec2 bottom_right_sample_uv =
      SCREEN_UV + vec2(pixel_size.x * half_scale_ceil, -pixel_size.y * half_scale_floor);
  vec2 top_left_sample_uv =
      SCREEN_UV + vec2(-pixel_size.x * half_scale_floor, pixel_size.y * half_scale_ceil);

  // depth-based edge detection
  float depth_bottom_left = textureLod(DEPTH_TEXTURE, bottom_left_sample_uv, 0.0).x;
  float depth_bottom_right = textureLod(DEPTH_TEXTURE, bottom_right_sample_uv, 0.0).x;
  float depth_top_left = textureLod(DEPTH_TEXTURE, top_left_sample_uv, 0.0).x;
  float depth_top_right = textureLod(DEPTH_TEXTURE, top_right_sample_uv, 0.0).x;

  float depth_roberts_cross = clamp(
                                  sqrt(
                                      pow(depth_top_right - depth_bottom_left, 2) +
                                      pow(depth_top_left - depth_bottom_right, 2)),
                                  0.0,
                                  1.0) *
      100.0;
  int depth_edge_confidence = int(depth_roberts_cross > depth_threshold_low) +
      int(depth_roberts_cross > depth_threshold_high);
  ALBEDO = mix(ALBEDO, outline_color.rgb, float(depth_edge_confidence) / 2.0);

  // color-based edge detection
  vec3 color_bottom_left = textureLod(SCREEN_TEXTURE, bottom_left_sample_uv, 0.0).rgb;
  float grayscale_bottom_left =
      (color_bottom_left.r + color_bottom_left.g + color_bottom_left.b) / 3.0;
  vec3 color_bottom_right = textureLod(SCREEN_TEXTURE, bottom_right_sample_uv, 0.0).rgb;
  float grayscale_bottom_right =
      (color_bottom_right.r + color_bottom_right.g + color_bottom_right.b) / 3.0;
  vec3 color_top_left = textureLod(SCREEN_TEXTURE, top_left_sample_uv, 0.0).rgb;
  float grayscale_top_left = (color_top_left.r + color_top_left.g + color_top_left.b) / 3.0;
  vec3 color_top_right = textureLod(SCREEN_TEXTURE, top_right_sample_uv, 0.0).rgb;
  float grayscale_top_right = (color_top_right.r + color_top_right.g + color_top_right.b) / 3.0;

  float color_roberts_cross = clamp(
      sqrt(
          pow(grayscale_top_right - grayscale_bottom_left, 2) +
          pow(grayscale_top_left - grayscale_bottom_right, 2)),
      0.0,
      1.0);
  float color_edge_confidence = smoothstep(color_threshold, color_threshold, color_roberts_cross);
  // if (color_edge_confidence > 0.0)
  // {
  //   ALBEDO = outline_color.rgb;
  // }

  // float edgeness = max(
  //     float(depth_edge_confidence == 2), float(depth_edge_confidence > 0) *
  //     color_edge_confidence);
  // float edgeness = max(
  //                      float(depth_edge_confidence == 2), color_edge_confidence);
  // ALBEDO = mix(ALBEDO, outline_color.rgb, edgeness);
}

#[vertex]
#version 450

#include "smaa_settings_inc.glsl"

layout(location = 0) in vec4 vert;
layout(location = 0) out vec2 tex_coord;
layout(location = 1) out vec4 offset[3];

void main() {
    tex_coord = vert.zw;
    offset[0] = fma(smaa.settings.SMAA_RT_METRICS.xyxy, vec4(-1.0, 0.0, 0.0, -1.0), tex_coord.xyxy);
    offset[1] = fma(smaa.settings.SMAA_RT_METRICS.xyxy, vec4(1.0, 0.0, 0.0, 1.0), tex_coord.xyxy);
    offset[2] = fma(smaa.settings.SMAA_RT_METRICS.xyxy, vec4(-2.0, 0.0, 0.0, -2.0), tex_coord.xyxy);
    gl_Position = vec4(vert.xy, 1.0, 1.0);
}

#[fragment]
#version 450

#include "smaa_settings_inc.glsl"

layout(location = 0) in vec2 tex_coord;
layout(location = 1) in vec4 offset[3];
layout(set = 1, binding = 0) uniform sampler2D color_tex;
layout(location = 0) out vec2 edges;

#define SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR 2.0

void main() {
    vec2 threshold = vec2(smaa.settings.threshold);
    
    vec4 delta;
    vec3 C = texture(color_tex, tex_coord).rgb;

    vec3 Cleft = texture(color_tex, offset[0].xy).rgb;
    vec3 t = abs(C - Cleft);
    delta.x = max(max(t.r, t.g), t.b);

    vec3 Ctop = texture(color_tex, offset[0].zw).rgb;
    t = abs(C - Ctop);
    delta.y = max(max(t.r, t.g), t.b);

    edges = step(threshold, delta.xy);

    if (dot(edges, vec2(1.0, 1.0)) == 0.0) {
        discard;
    }

    vec3 Cright = texture(color_tex, offset[1].xy).rgb;
    t = abs(C - Cright);
    delta.z = max(max(t.r, t.g), t.b);

    vec3 Cbottom = texture(color_tex, offset[1].zw).rgb;
    t = abs(C - Cbottom);
    delta.w = max(max(t.r, t.g), t.b);

    vec2 max_delta = max(delta.xy, delta.zw);

    vec3 Cleftleft = texture(color_tex, offset[2].xy).rgb;
    t = abs(Cleft - Cleftleft);
    delta.z = max(max(t.r, t.g), t.b);

    vec3 Ctoptop = texture(color_tex, offset[2].zw).rgb;
    t = abs(Ctop - Ctoptop);
    delta.w = max(max(t.r, t.g), t.b);

    max_delta = max(max_delta.xy, delta.zw);
    float final_delta = max(max_delta.x, max_delta.y);

    edges.xy *= step(final_delta, SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR * delta.xy);
}

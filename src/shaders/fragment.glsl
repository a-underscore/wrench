#version 450

#define MAX_LIGHTS 1024

struct Light {
    vec3 position;
    mat4 rotation;
    vec4 color;
    bool directional;
    float intensity;
    float cutoff;
    float attenuation;
};

struct LightArray {
    uint len;
    Light array[MAX_LIGHTS];
};

layout(location = 0) in vec3 normal;
layout(location = 1) in vec2 tex_coord;
layout(location = 2) in vec3 f_pos;
layout(location = 3) in mat3 global_translation;
layout(location = 6) in mat3 cam_translation;

layout(location = 0) out vec4 f_color;

layout(set = 0, binding = 1) uniform sampler2D tex;

layout(set = 0, binding = 2) uniform Data {
    vec4 color;
    float ambient;
    float diff_strength;
    float spec_strength;
    uint spec_power;
    LightArray lights;
} uniforms;

void main() {
    vec4 tex_color = texture(tex, tex_coord);

    if (tex_color.a == 0.0) {
      discard;
    }

    vec3 norm = normalize(global_translation * normal);

    mat3 cam_offset = -mat3(cam_translation);

    vec4 brightness = vec4(uniforms.ambient);

    for (uint i = 0; i < uniforms.lights.len; i++) {
        Light light = uniforms.lights.array[i];
        
        float attenuation = 1.0;

        vec3 light_dir = normalize(cam_offset * uniforms.lights.array[i].position - f_pos);
        vec3 view_dir = normalize(cam_translation * f_pos);

        if (light.directional) {
          float theta = dot(-light_dir, -normalize(vec3(1.0) * mat3(light.rotation)));

          if (theta > light.cutoff) {
            mat3 light_rotation_global = inverse(mat3(light.rotation));

            light_dir *= light_rotation_global;
            view_dir *= light_rotation_global;

            float distance = length(light.position - f_pos);

            attenuation = 1.0 / (light.attenuation * pow(distance, 2));
          } else {
            continue;
          }
        }

        vec3 reflect_dir = reflect(norm, -light_dir);

        float diff = max(dot(norm, light_dir), 0.0) * uniforms.diff_strength;
        float spec = pow(max(dot(view_dir, reflect_dir), 0.0), uniforms.spec_power) * uniforms.spec_strength;

        brightness += (diff + spec) * uniforms.lights.array[i].intensity * uniforms.lights.array[i].color * attenuation;
    }
    
    f_color = tex_color * uniforms.color * brightness;
}

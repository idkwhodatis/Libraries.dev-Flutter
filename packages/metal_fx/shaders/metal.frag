#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uStrength;
uniform float uPreset;
uniform vec2 uPointer;
uniform float uHasPointer;

out vec4 fragColor;

float hash21(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  float a = hash21(i);
  float b = hash21(i + vec2(1.0, 0.0));
  float c = hash21(i + vec2(0.0, 1.0));
  float d = hash21(i + vec2(1.0, 1.0));
  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float amp = 0.5;
  for (int i = 0; i < 3; i++) {
    v += amp * noise(p);
    p = p * 2.03 + vec2(11.7, 5.3);
    amp *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / max(uSize, vec2(1.0));
  float t = uTime * 6.2831853;
  float n = fbm(uv * 2.2 + vec2(t * 0.06, -t * 0.045));

  float broad = sin((uv.x * 2.2 + uv.y * 0.9 + n * 1.1 + t * 0.10) * 2.0);
  float fine = sin((uv.x * 5.5 - uv.y * 1.6 - n * 0.8 - t * 0.07) * 2.0);
  float metal = smoothstep(0.15, 0.88, 0.5 + 0.5 * broad);
  float detail = 0.5 + 0.5 * fine;

  vec3 silver = mix(vec3(0.10, 0.12, 0.16), vec3(0.94, 0.97, 1.0), metal);
  silver = mix(silver, vec3(0.52, 0.58, 0.68), detail * 0.22);
  vec3 gold = mix(vec3(0.12, 0.055, 0.008), vec3(1.0, 0.80, 0.30), metal);
  gold = mix(gold, vec3(0.62, 0.35, 0.06), detail * 0.25);
  vec3 chromatic = mix(vec3(0.20, 0.28, 0.48), vec3(0.95, 0.48, 0.88), metal);
  chromatic = mix(chromatic, vec3(0.18, 0.85, 0.82), detail * 0.35);

  vec3 base = uPreset < 0.5 ? silver : (uPreset < 1.5 ? gold : chromatic);

  float glint = exp(-pow((uv.x * 0.75 + uv.y * 0.55 - 0.50 + n * 0.04) * 3.0, 2.0));
  float edge = smoothstep(0.0, 0.08, uv.y) * smoothstep(1.0, 0.92, uv.y);
  vec3 color = base + vec3(glint * 0.22);
  float lightDist = distance(uv, uPointer);
  float pointerLight = exp(-lightDist * lightDist * 9.0) * uHasPointer;
  color += vec3(0.82, 0.86, 0.92) * pointerLight * 0.35;
  color *= 0.88 + 0.18 * n;
  color = clamp(color, 0.0, 1.0) * uStrength;
  fragColor = vec4(color, 1.0) * edge;
}



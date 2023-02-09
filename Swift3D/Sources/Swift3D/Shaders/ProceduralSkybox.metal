#include <metal_stdlib>
using namespace metal;

#include "SharedData.h"
#include "Lighting.h"
#include "SimplexNoise.h"

// -- Helpers

float3 spectral_spektre (float x)
{
  float l = saturate(x) * 150 + 405;

    float r=0.0,g=0.0,b=0.0;
            if ((l>=400.0)&&(l<410.0)) { float t=(l-400.0)/(410.0-400.0); r=    +(0.33*t)-(0.20*t*t); }
    else if ((l>=410.0)&&(l<475.0)) { float t=(l-410.0)/(475.0-410.0); r=0.14         -(0.13*t*t); }
    else if ((l>=545.0)&&(l<595.0)) { float t=(l-545.0)/(595.0-545.0); r=    +(1.98*t)-(     t*t); }
    else if ((l>=595.0)&&(l<650.0)) { float t=(l-595.0)/(650.0-595.0); r=0.98+(0.06*t)-(0.40*t*t); }
    else if ((l>=650.0)&&(l<700.0)) { float t=(l-650.0)/(700.0-650.0); r=0.65-(0.84*t)+(0.20*t*t); }
            if ((l>=415.0)&&(l<475.0)) { float t=(l-415.0)/(475.0-415.0); g=             +(0.80*t*t); }
    else if ((l>=475.0)&&(l<590.0)) { float t=(l-475.0)/(590.0-475.0); g=0.8 +(0.76*t)-(0.80*t*t); }
    else if ((l>=585.0)&&(l<639.0)) { float t=(l-585.0)/(639.0-585.0); g=0.82-(0.80*t)           ; }
            if ((l>=400.0)&&(l<475.0)) { float t=(l-400.0)/(475.0-400.0); b=    +(2.20*t)-(1.50*t*t); }
    else if ((l>=475.0)&&(l<560.0)) { float t=(l-475.0)/(560.0-475.0); b=0.7 -(     t)+(0.30*t*t); }

    return float3(r,g,b);
}



// -- Uniform

struct VertexOut {
  float4 position [[position]];  //1
  float4 clipPosition;
};

// -- Vert

vertex VertexOut procedural_skybox_vertex(const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           const device Lights& lights [[ buffer(3) ]],
                           // const device SkyboxProperties& material [[ buffer(4) ]],
                           unsigned int vid [[ vertex_id ]]) {
  // Viewport covering triangle.
  float2 positions[] = {
      { -1, 1 },
      { -1, -3 },
      { 3, 1 }
    };

  VertexOut out;
  out.position = float4(positions[vid].xy, 1, 1);
  out.clipPosition = out.position;
  return out;
}

// -- Frag

struct Properties {
  float4 time;
  float4 low;
  float4 mid;
  float4 high;
};

fragment float4 procedural_skybox_fragment(VertexOut in [[stage_in]],
                                constant float4x4 &clipToViewMatrix [[ buffer(0) ]],
                                constant Properties &properties [[ buffer(2) ]]) {
  float4 worldPosition = clipToViewMatrix * in.clipPosition;
  float3 worldDirection = normalize(worldPosition.xyz);
  float3 gradient = mix(properties.low.xyz, properties.high.xyz, saturate(worldDirection.y));
  float3 horizonGlow = mix(gradient, properties.mid.xyz, saturate(1 - abs(worldDirection.y)));

  return float4(horizonGlow, 1);
}

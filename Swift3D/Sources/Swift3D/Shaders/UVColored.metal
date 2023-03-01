#include <metal_stdlib>
using namespace metal;

#include "Common.h"


// ---------- Color Generation

// Based on GPU Gems
// Optimised by Alan Zucconi
inline float3 bump3y (float3 x, float3 yoffset)
{
    float3 y = 1 - x * x;
    y = saturate(y-yoffset);
    return y;
}

float3 spectral_zucconi (float x)
{
    // w: [400, 700]
    // x: [0,   1]

    const float3 cs = float3(3.54541723, 2.86670055, 2.29421995);
    const float3 xs = float3(0.69548916, 0.49416934, 0.28269708);
    const float3 ys = float3(0.02320775, 0.15936245, 0.53520021);

  return bump3y (cs * (x - xs), ys);//* sin(x * 3.14159);
}

float3 uvColor(float2 uv) {
  return saturate(spectral_zucconi(uv.x) + spectral_zucconi(uv.y));
}

struct VertexOut {
  float4 position [[position]];  //1
  float3 worldPos;
  float3 viewPos;
  float3 worldNormal;
  float3 uvColor;
};

// --

vertex VertexOut uv_color_vertex(VertexIn in [[stage_in]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]]) {
  float4x4 m_matrix =   uniforms.modelMatrix;
  float4x4 mv_matrix =  vpUniforms.viewMatrix * uniforms.modelMatrix;
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;

  VertexOut out {
    .position = mvp_matrix * float4(in.position, 1.0),
    .worldPos = (m_matrix * float4(in.position, 1.0)).xyz,
    

    .viewPos = (mv_matrix * float4(in.position, 1.0)).xyz,
    .worldNormal = normalize((m_matrix * float4(in.normal, 0.0))).xyz,
    .uvColor = uvColor(in.uv)
  };

  return out;
}

fragment float4 uv_color_fragment(VertexOut in [[stage_in]],
                                  constant FragmentUniforms &uniforms [[ buffer(0) ]],
                                  constant MaterialProperties &material [[ buffer(1) ]],
                                  constant Light *lights [[ buffer(2) ]]) {

  float3 finalColor = float3(0);

  float3 viewDirection = normalize(in.worldPos - uniforms.cameraPos.xyz);

  for (uint i = 0; i < uniforms.lightData.x; i++) {
    finalColor += calculateLightingSpecular(lights[i], material, in.worldNormal, viewDirection, in.worldPos);
  }

  return float4((finalColor + in.uvColor) * 0.5, 1);
}

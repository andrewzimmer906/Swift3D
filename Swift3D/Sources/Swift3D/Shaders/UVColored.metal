#include <metal_stdlib>
using namespace metal;

#include "Common.h"


// ---------- Color Generation

inline float3 bump3 (float3 x)
{
    float3 y = 1 - x * x;
    y = max(y, 0);
    return y;
}

float3 spectral_gems (float x)
{
       // w: [400, 700]
    // x: [0,   1]
    // fixed x = saturate((w - 400.0)/300.0);

    return bump3
    (    float3
        (
            4 * (x - 0.75),    // Red
            4 * (x - 0.5),    // Green
            4 * (x - 0.25)    // Blue
        )
    );
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
    .uvColor = spectral_gems((in.uv.x + in.uv.y) * 0.5)
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
    finalColor += calculateLightingSpecular(lights[i], material, in.worldNormal, viewDirection);
  }

  return float4((finalColor + in.uvColor) * 0.5, 1);
}

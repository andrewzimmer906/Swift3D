#include <metal_stdlib>
using namespace metal;

#include "Common.h"

struct VertexOut {
  float4 position [[position]];  //1
  float2 uv;
  float3 worldPos;
  float3 viewPos;
  float3 worldNormal;
};

// --

vertex VertexOut pbr_vertex(VertexIn in [[stage_in]],
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
    .uv = in.uv
  };

  return out;
}

fragment float4 pbr_fragment(VertexOut in [[stage_in]],
                                  texture2d<float> baseColor [[ texture(FragmentTextureBaseColor) ]],
                                  constant FragmentUniforms &uniforms [[ buffer(0) ]],
                                  constant MaterialProperties &material [[ buffer(1) ]],
                                  constant Light *lights [[ buffer(2) ]]) {

  float3 albedoColor = baseColor.sample(textureSampler, in.uv * material.albedoTextureScaling.xy).xyz;
  float3 finalColor = float3(0);

  float3 viewDirection = normalize(in.worldPos - uniforms.cameraPos.xyz);

  for (uint i = 0; i < uniforms.lightData.x; i++) {
    finalColor += calculateLightingSpecular(lights[i], material, in.worldNormal, viewDirection);
  }

  return float4(finalColor * albedoColor, 1);
}

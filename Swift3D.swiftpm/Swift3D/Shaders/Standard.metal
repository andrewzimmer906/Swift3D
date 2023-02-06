#include <metal_stdlib>
using namespace metal;

#include "SharedData.h"
#include "Lighting.h"

struct VertexOut {
  float4 position [[position]];  //1
  float2 uv;
  float4 worldPos;
  float4 viewPos;
  float4 normal;
  float4 normalV;
};

// --

vertex VertexOut standard_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           unsigned int vid [[ vertex_id ]]) {
  VertexIn in = vertex_array[vid];
  VertexOut out;
  
  float4x4 m_matrix = uniforms.modelMatrix;
  float4x4 mv_matrix =  vpUniforms.viewMatrix * uniforms.modelMatrix;
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;
  
  out.position = mvp_matrix * float4(in.position, 1.0);
  out.worldPos = m_matrix * float4(in.position, 1.0);
  out.viewPos = mv_matrix * float4(in.position, 1.0);
  out.normal = normalize((m_matrix * float4(in.normal, 0.0)));
  out.normalV = normalize((mv_matrix * float4(in.normal, 0.0)));

  out.uv = in.uv;

  return out;
}

fragment float4 standard_fragment(VertexOut in [[stage_in]],
                                  texture2d<float> albedo [[ texture(0) ]],
                                  constant MaterialProperties &material [[ buffer(0) ]],
                                  constant Lights &lights [[ buffer(1) ]]) {
  const float4 color = albedo.sample(textureSampler, in.uv * material.albedoTextureScaling.xy);
  float3 lighting = calculateLighting(lights, material, in.normal.xyz, in.normalV.xyz, in.viewPos);
  return float4((lighting * color.xyz).xyz, 1.0);
}

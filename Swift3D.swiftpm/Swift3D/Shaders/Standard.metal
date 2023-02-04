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
  Lights lights;
  MaterialProperties material;
};

// --

vertex VertexOut standard_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           const device Lights& lights [[ buffer(3) ]],
                           const device MaterialProperties& material [[ buffer(4) ]],
                                   
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
  
  out.material = material;
  out.lights = lights;
  out.uv = in.uv;

  return out;
}

fragment float4 standard_fragment(VertexOut in [[stage_in]],
                                  texture2d<float> albedo [[ texture(0) ]]) {
  const float4 color = albedo.sample(textureSampler, in.uv * in.material.albedoTextureScaling.xy);
  float3 lighting = calculateLighting(in.lights, in.material, in.normal.xyz, in.normalV.xyz, in.viewPos);
  //lighting = in.viewPos.xyz * 0.5 + 0.5;
  return float4((lighting * color.xyz).xyz, 1.0);
}

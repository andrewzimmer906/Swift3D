#include <metal_stdlib>
using namespace metal;

struct Uniforms {
  float4x4 modelMatrix;
};

struct ViewProjectionUniform {
  float4x4 projectionMatrix;
  float4x4 viewMatrix;
};

struct VertexIn {
  float3 position;
  float2 uv;
  float3 normal;
};

struct VertexOut {
  float4 position [[position]];  //1
  float3 normal;
  float3 color;
};

vertex VertexOut simple_lit_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           unsigned int vid [[ vertex_id ]]) {
  VertexIn in = vertex_array[vid];
  VertexOut out;
  
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;
  out.position = mvp_matrix * float4(in.position, 1.0);
  out.normal = (uniforms.modelMatrix * float4(in.normal, 0.0)).xyz;
  
  out.color = float3(0.5) + in.normal * 0.5;
  
  return out;
}

fragment float4 simple_lit_fragment(VertexOut in [[stage_in]]) {
  float3 fakeAmbient = float3(0.15);
  float3 fakeDirectionalLightColor = float3(1, 1, 0);
  float3 fakeDirectionalLight = float3(-0.5, 0.5, 0.5);
  
  float diffuseFactor = saturate(dot(in.normal, fakeDirectionalLight));
  float3 diffuse = diffuseFactor * fakeDirectionalLightColor;
  return float4((fakeAmbient + diffuse).xyz, 1.0);
  
  
  //return half4(in.normal.x, in.normal.y, in.normal.z, 1);  
  //return half4(interpolated.color.x, interpolated.color.y, interpolated.color.z, 0);
}

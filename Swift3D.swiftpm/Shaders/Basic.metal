#include <metal_stdlib>
using namespace metal;

struct Uniforms {
  float4x4 modelMatrix;
};

struct ViewProjectionUniform {
  float4x4 projectionMatrix;
  float4x4 viewMatrix;
};

vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           unsigned int vid [[ vertex_id ]]) {  
  
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;
  float4 pos = mvp_matrix * float4(vertex_array[vid], 1.0);
  
  return pos;
}

fragment half4 basic_fragment() {
  return half4(1.0);
}


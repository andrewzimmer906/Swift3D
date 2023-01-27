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

struct VertexIn{
  float3 position;
  float4 color;
};

struct VertexOut{
  float4 position [[position]];  //1
  float4 color;
};


vertex VertexOut basic_col_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           unsigned int vid [[ vertex_id ]]) {
  VertexIn in = vertex_array[vid];
  VertexOut out;
  
  
  
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;
  out.position = mvp_matrix * float4(in.position, 1.0);
  out.color = in.color;
  
  return out;
}

fragment half4 basic_col_fragment(VertexOut interpolated [[stage_in]]) {
  return half4(interpolated.color);
}

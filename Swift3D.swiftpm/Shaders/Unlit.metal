#include <metal_stdlib>
using namespace metal;

#include "SharedData.h"
#include "Lighting.h"

struct VertexOut {
  float4 position [[position]];  //1  
  float4 color;
};

// --

vertex VertexOut unlit_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           const device Lights& lights [[ buffer(3) ]],
                           const device CustomShaderUniform& customValues [[ buffer(4) ]],
                                   
                           unsigned int vid [[ vertex_id ]]) {
  VertexIn in = vertex_array[vid];
  VertexOut out;
  
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;
  
  out.position = mvp_matrix * float4(in.position, 1.0);
  out.color = customValues.textureColor; //float3(0.5) + in.normal * 0.5;
  
  return out;
}

fragment float4 unlit_fragment(VertexOut in [[stage_in]]) {
  return in.color;
}

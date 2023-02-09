#include <metal_stdlib>
using namespace metal;

#include "SharedData.h"
#include "Lighting.h"

struct VertexOut {
  float4 position [[position]];  //1
};

struct CustomShaderUniform {
  float4 textureColor;
};

// --

vertex VertexOut unlit_vertex(VertexIn in [[stage_in]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           const device Lights& lights [[ buffer(3) ]]) {
  VertexOut out;
  
  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;
  
  out.position = mvp_matrix * float4(in.position, 1.0);
  
  return out;
}

fragment float4 unlit_fragment(VertexOut in [[stage_in]],
                               constant float4 &material [[ buffer(0) ]]) {
  return material;
}

#include <metal_stdlib>
using namespace metal;

#include "SharedData.h"
#include "Lighting.h"

struct SkyboxProperties {
  float4 textureScaling;
};

struct VertexOut {
  float4 position [[position]];  //1
  float2 uv;
  SkyboxProperties material;
};

// --

vertex VertexOut skybox_vertex(const device VertexIn* vertex_array [[ buffer(0) ]],
                           const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           const device Lights& lights [[ buffer(3) ]],
                           const device SkyboxProperties& material [[ buffer(4) ]],

                           unsigned int vid [[ vertex_id ]]) {
  VertexIn in = vertex_array[vid];
  VertexOut out;

  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;

  out.position = mvp_matrix * float4(in.position, 1.0);
  out.uv = in.uv;
  out.material = material;

  return out;
}

fragment float4 skybox_fragment(VertexOut in [[stage_in]],
                                  texture2d<float> albedo [[ texture(0) ]]) {
  const float4 color = albedo.sample(textureSampler, in.uv * in.material.textureScaling.xy);
  return color;
}

#include <metal_stdlib>
using namespace metal;

#include "SharedData.h"
#include "Lighting.h"

struct VertexOut {
  float4 position [[position]];  //1
  float4 clipPosition;
  float4 worldPosition;
};

// --

vertex VertexOut skybox_vertex(const device Uniforms& uniforms [[ buffer(1) ]],
                           const device ViewProjectionUniform& vpUniforms [[ buffer(2) ]],
                           const device Lights& lights [[ buffer(3) ]],
                           // const device SkyboxProperties& material [[ buffer(4) ]],
                           unsigned int vid [[ vertex_id ]]) {
  // Viewport covering triangle.
  float2 positions[] = {
      { -1, 1 },
      { -1, -3 },
      { 3, 1 }
    };
  VertexOut out;
  out.position = float4(positions[vid].xy, 1, 1);
  out.clipPosition = out.position;
  out.worldPosition = out.position * vpUniforms.clipToViewMatrix;

  return out;

/*
  VertexIn in = vertex_array[vid];


  float4x4 mvp_matrix = vpUniforms.projectionMatrix * vpUniforms.viewMatrix * uniforms.modelMatrix;

  // Z is always 1 for skybox that way it's at max depth!
  float4 posOut = mvp_matrix * float4(in.position.xyz, 1.0);
  out.position = float4(posOut.xy, 0.999, posOut.w);

  out.uv = in.uv;
  out.material = material;
*/

  return out;
}

fragment float4 skybox_fragment(VertexOut in [[stage_in]],
                                constant float4x4 &clipToViewMatrix [[ buffer(0) ]],
                                texturecube<float, access::sample> cubeTexture [[ texture(0) ]],
                                sampler cubeSampler [[sampler(0)]]) {
  float4 worldPosition = clipToViewMatrix * in.clipPosition;
  float3 worldDirection = normalize(worldPosition.xyz);
  // return float4(worldDirection.xyz, 1);
  return cubeTexture.sample(cubeSampler, worldDirection);
  // const float4 color = albedo.sample(textureSampler, in.uv * in.material.textureScaling.xy);
  // return color;
}
